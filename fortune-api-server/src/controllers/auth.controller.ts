import { Request, Response, NextFunction } from 'express';
import { supabaseAdmin, verifyUser } from '../lib/supabase';
import { tokenService } from '../services/token.service';
import logger from '../utils/logger';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';

// Register new user
export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password, name, birthDate } = req.body;

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

    if (authError) {
      if (authError.message.includes('already registered')) {
        return res.status(409).json({
          success: false,
          error: 'Email already registered'
        });
      }
      throw authError;
    }

    const userId = authData.user.id;

    // Create user profile
    const { error: profileError } = await supabaseAdmin
      .from('user_profiles')
      .insert({
        id: userId,
        email,
        name,
        birth_date: birthDate,
        onboarding_completed: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

    if (profileError) {
      // Rollback: delete auth user
      await supabaseAdmin.auth.admin.deleteUser(userId);
      throw profileError;
    }

    // Initialize user tokens (10 free tokens for new users)
    await tokenService.initializeUserTokens(userId, 10);

    // Generate session token
    const { data: sessionData, error: sessionError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: email,
      options: {
        redirectTo: `${process.env.FRONTEND_URL}/auth/callback`
      }
    });

    if (sessionError) throw sessionError;

    logger.info(`New user registered: ${userId}`);

    return res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: {
          id: userId,
          email,
          name
        }
      }
    });

  } catch (error) {
    logger.error('Registration error:', error);
    next(error);
  }
};

// Login user
export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    // Sign in with Supabase Auth
    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      if (error.message.includes('Invalid login credentials')) {
        return res.status(401).json({
          success: false,
          error: 'Invalid email or password'
        });
      }
      throw error;
    }

    // Get user profile
    const { data: profile } = await supabaseAdmin
      .from('user_profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    // Get token balance
    const tokenBalance = await tokenService.getTokenBalance(data.user.id);

    logger.info(`User logged in: ${data.user.id}`);

    return res.json({
      success: true,
      data: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        user: {
          id: data.user.id,
          email: data.user.email,
          name: profile?.name || '',
          profile: profile,
          token_balance: tokenBalance.balance,
          is_unlimited: tokenBalance.isUnlimited,
          subscription_plan: tokenBalance.subscriptionPlan
        }
      }
    });

  } catch (error) {
    logger.error('Login error:', error);
    next(error);
  }
};

// Refresh token
export const refreshToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(400).json({
        success: false,
        error: 'Refresh token is required'
      });
    }

    // Refresh session with Supabase
    const { data, error } = await supabaseAdmin.auth.refreshSession({
      refresh_token
    });

    if (error) {
      return res.status(401).json({
        success: false,
        error: 'Invalid refresh token'
      });
    }

    return res.json({
      success: true,
      data: {
        access_token: data.session?.access_token,
        refresh_token: data.session?.refresh_token,
        user: data.user
      }
    });

  } catch (error) {
    logger.error('Refresh token error:', error);
    next(error);
  }
};

// OAuth callback handler
export const oauthCallback = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { code, state, error, error_description } = req.query;

    if (error) {
      logger.error('OAuth callback error:', { error, error_description });
      return res.redirect(`${process.env.FRONTEND_URL}/auth/error?error=${encodeURIComponent(error as string)}`);
    }

    if (!code) {
      return res.redirect(`${process.env.FRONTEND_URL}/auth/error?error=no_code`);
    }

    // Exchange code for session
    const { data, error: exchangeError } = await supabaseAdmin.auth.exchangeCodeForSession(code as string);

    if (exchangeError || !data.session) {
      logger.error('Code exchange error:', exchangeError);
      return res.redirect(`${process.env.FRONTEND_URL}/auth/error?error=exchange_failed`);
    }

    const userId = data.user.id;

    // Check if user profile exists
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (profileError || !profile) {
      // Create profile for OAuth users
      await supabaseAdmin
        .from('user_profiles')
        .insert({
          id: userId,
          email: data.user.email,
          name: data.user.user_metadata?.full_name || data.user.email?.split('@')[0] || 'User',
          avatar_url: data.user.user_metadata?.avatar_url,
          onboarding_completed: false,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        });

      // Initialize tokens for new OAuth users
      await tokenService.initializeUserTokens(userId, 10);
    }

    // Generate JWT for API access
    const apiToken = jwt.sign(
      { 
        userId: userId,
        email: data.user.email,
        sessionId: data.session.access_token
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    // Redirect to frontend with tokens
    const redirectUrl = new URL(`${process.env.FRONTEND_URL}/auth/success`);
    redirectUrl.searchParams.set('access_token', data.session.access_token);
    redirectUrl.searchParams.set('refresh_token', data.session.refresh_token);
    redirectUrl.searchParams.set('api_token', apiToken);

    return res.redirect(redirectUrl.toString());

  } catch (error) {
    logger.error('OAuth callback error:', error);
    return res.redirect(`${process.env.FRONTEND_URL}/auth/error?error=internal_error`);
  }
};

// Logout user
export const logout = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    // Get the authorization header
    const authHeader = req.headers.authorization;
    const token = authHeader?.replace('Bearer ', '');

    if (token) {
      // Sign out from Supabase
      const { error } = await supabaseAdmin.auth.admin.signOut(token);
      if (error) {
        logger.warn('Supabase signout error:', error);
      }
    }

    logger.info(`User logged out: ${userId}`);

    return res.json({
      success: true,
      message: 'Logged out successfully'
    });

  } catch (error) {
    logger.error('Logout error:', error);
    next(error);
  }
};

// Get current session
export const getSession = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    // Get user profile
    const { data: profile } = await supabaseAdmin
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();

    // Get token balance
    const tokenBalance = await tokenService.getTokenBalance(userId);

    return res.json({
      success: true,
      data: {
        user: {
          id: userId,
          email: req.user?.email,
          profile: profile,
          token_balance: tokenBalance.balance,
          is_unlimited: tokenBalance.isUnlimited,
          subscription_plan: tokenBalance.subscriptionPlan
        }
      }
    });

  } catch (error) {
    logger.error('Get session error:', error);
    next(error);
  }
};

// Change password
export const changePassword = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    const { currentPassword, newPassword } = req.body;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    // Verify current password first
    const { data: userData } = await supabaseAdmin.auth.admin.getUserById(userId);
    if (!userData.user?.email) {
      throw new Error('User email not found');
    }

    // Try to sign in with current password to verify it
    const { error: verifyError } = await supabaseAdmin.auth.signInWithPassword({
      email: userData.user.email,
      password: currentPassword
    });

    if (verifyError) {
      return res.status(401).json({
        success: false,
        error: 'Current password is incorrect'
      });
    }

    // Update password
    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      userId,
      { password: newPassword }
    );

    if (updateError) {
      throw updateError;
    }

    logger.info(`Password changed for user: ${userId}`);

    return res.json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    logger.error('Change password error:', error);
    next(error);
  }
};