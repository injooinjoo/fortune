import { Request, Response, NextFunction } from 'express';
import { fortuneService, FortuneCategory } from '../services/fortune.service';
import { tokenService } from '../services/token.service';
import logger from '../utils/logger';
import { supabaseAdmin } from '../lib/supabase';

// Generic fortune handler factory
const createFortuneHandler = (category: FortuneCategory) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({
          success: false,
          error: 'Unauthorized'
        });
      }

      // Get user profile
      const { data: userProfile } = await supabaseAdmin
        .from('user_profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (!userProfile) {
        return res.status(404).json({
          success: false,
          error: 'User profile not found'
        });
      }

      // Check token balance
      const hasTokens = await tokenService.hasEnoughTokens(userId, category);
      if (!hasTokens) {
        const cost = tokenService['getTokenCostForCategory'](category);
        return res.status(402).json({
          success: false,
          error: 'Insufficient tokens',
          required_tokens: cost
        });
      }

      // Deduct tokens
      const deductionResult = await tokenService.deductTokens(userId, category);
      if (!deductionResult.success) {
        return res.status(402).json({
          success: false,
          error: deductionResult.error
        });
      }

      // Generate or get cached fortune
      const fortuneResult = await fortuneService.getOrCreateFortune(
        userId,
        category,
        userProfile,
        req.body.interactiveInput
      );

      if (!fortuneResult.success) {
        // Refund tokens on failure
        const cost = tokenService['getTokenCostForCategory'](category);
        await tokenService.addTokens(
          userId,
          cost,
          'refund',
          `Failed to generate ${category} fortune`
        );

        return res.status(500).json({
          success: false,
          error: fortuneResult.error
        });
      }

      return res.json({
        success: true,
        data: fortuneResult.data,
        cached: fortuneResult.cached,
        cache_source: fortuneResult.cache_source,
        generated_at: fortuneResult.generated_at,
        token_balance: deductionResult.newBalance
      });

    } catch (error) {
      logger.error(`Fortune controller error (${category}):`, error);
      next(error);
    }
  };
};

// Daily fortune handlers
export const getDailyFortune = createFortuneHandler('daily');
export const getTodayFortune = createFortuneHandler('today');
export const getTomorrowFortune = createFortuneHandler('tomorrow');
export const getWeeklyFortune = createFortuneHandler('daily'); // Map weekly to daily
export const getMonthlyFortune = createFortuneHandler('daily'); // Map monthly to daily
export const getYearlyFortune = createFortuneHandler('daily'); // Map yearly to daily
export const getHourlyFortune = createFortuneHandler('hourly');

// Traditional fortune handlers
export const getSajuFortune = createFortuneHandler('saju');
export const getTraditionalSajuFortune = createFortuneHandler('traditional-saju');
export const getSajuPsychologyFortune = createFortuneHandler('saju-psychology');
export const getTojeongFortune = createFortuneHandler('tojeong');
export const getSalpuliFortune = createFortuneHandler('salpuli');
export const getPalmistryFortune = createFortuneHandler('palmistry');
export const getPhysiognomyFortune = createFortuneHandler('physiognomy');

// Personality fortune handlers
export const getMbtiFortune = createFortuneHandler('mbti');
export const getPersonalityFortune = createFortuneHandler('mbti'); // Map personality to mbti
export const getBloodTypeFortune = createFortuneHandler('blood-type');

// Love & relationship fortune handlers
export const getLoveFortune = createFortuneHandler('love');
export const getMarriageFortune = createFortuneHandler('marriage');
export const getCompatibilityFortune = createFortuneHandler('compatibility');
export const getTraditionalCompatibilityFortune = createFortuneHandler('traditional-compatibility');
export const getCoupleMatchFortune = createFortuneHandler('couple-match');
export const getBlindDateFortune = createFortuneHandler('blind-date');
export const getExLoverFortune = createFortuneHandler('ex-lover');
export const getCelebrityMatchFortune = createFortuneHandler('celebrity-match');
export const getChemistryFortune = createFortuneHandler('chemistry');

// Career & business fortune handlers
export const getCareerFortune = createFortuneHandler('career');
export const getEmploymentFortune = createFortuneHandler('employment');
export const getBusinessFortune = createFortuneHandler('business');
export const getStartupFortune = createFortuneHandler('startup');
export const getLuckyJobFortune = createFortuneHandler('lucky-job');

// Wealth & investment fortune handlers
export const getWealthFortune = createFortuneHandler('wealth');
export const getLuckyInvestmentFortune = createFortuneHandler('lucky-investment');
export const getLuckyRealEstateFortune = createFortuneHandler('lucky-realestate');
export const getLuckySideJobFortune = createFortuneHandler('lucky-sidejob');

// Health & lifestyle fortune handlers
export const getBiorhythmFortune = createFortuneHandler('biorhythm');
export const getMovingFortune = createFortuneHandler('moving');
export const getMovingDateFortune = createFortuneHandler('moving-date');
export const getAvoidPeopleFortune = createFortuneHandler('avoid-people');

// Sports & activity fortune handlers
export const getLuckyHikingFortune = createFortuneHandler('lucky-hiking');
export const getLuckyCyclingFortune = createFortuneHandler('lucky-cycling');
export const getLuckyRunningFortune = createFortuneHandler('lucky-running');
export const getLuckySwimFortune = createFortuneHandler('lucky-swim');
export const getLuckyTennisFortune = createFortuneHandler('lucky-tennis');
export const getLuckyGolfFortune = createFortuneHandler('lucky-golf');
export const getLuckyBaseballFortune = createFortuneHandler('lucky-baseball');
export const getLuckyFishingFortune = createFortuneHandler('lucky-fishing');

// Lucky items fortune handlers
export const getLuckyColorFortune = createFortuneHandler('lucky-color');
export const getLuckyNumberFortune = createFortuneHandler('lucky-number');
export const getLuckyItemsFortune = createFortuneHandler('lucky-items');
export const getLuckyOutfitFortune = createFortuneHandler('lucky-outfit');
export const getLuckyFoodFortune = createFortuneHandler('lucky-food');
export const getLuckyExamFortune = createFortuneHandler('lucky-exam');
export const getTalismanFortune = createFortuneHandler('talisman');

// Special fortune handlers
export const getZodiacFortune = createFortuneHandler('zodiac');
export const getZodiacAnimalFortune = createFortuneHandler('zodiac-animal');
export const getBirthSeasonFortune = createFortuneHandler('birth-season');
export const getBirthstoneFortune = createFortuneHandler('birthstone');
export const getBirthdateFortune = createFortuneHandler('birthdate');
export const getPastLifeFortune = createFortuneHandler('past-life');
export const getNewYearFortune = createFortuneHandler('new-year');
export const getTalentFortune = createFortuneHandler('talent');
export const getFiveBlessingsFortune = createFortuneHandler('five-blessings');
export const getNetworkReportFortune = createFortuneHandler('network-report');
export const getTimelineFortune = createFortuneHandler('timeline');
export const getWishFortune = createFortuneHandler('wish');
export const getDestinyFortune = createFortuneHandler('destiny');

// Additional handlers not mapped to specific categories
export const getCelebrityFortune = createFortuneHandler('celebrity-match');
export const getLuckySeriesFortune = createFortuneHandler('lucky-items');

// Interactive fortune handlers
export const getTarotFortune = createFortuneHandler('tarot');
export const getDreamInterpretationFortune = createFortuneHandler('dream-interpretation');
export const getWorryBeadFortune = createFortuneHandler('worry-bead');

// Dynamic category handler
export const getFortuneByCategory = async (req: Request, res: Response, next: NextFunction) => {
  const category = req.params.category as FortuneCategory;
  const handler = createFortuneHandler(category);
  return handler(req, res, next);
};

// Generate single fortune (generic endpoint)
export const generateFortune = async (req: Request, res: Response, next: NextFunction) => {
  const { category } = req.body;
  if (!category) {
    return res.status(400).json({
      success: false,
      error: 'Fortune category is required'
    });
  }
  const handler = createFortuneHandler(category);
  return handler(req, res, next);
};

// Generate batch fortunes
export const generateBatchFortune = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    const { fortuneTypes, targetDate } = req.body;

    if (!fortuneTypes || !Array.isArray(fortuneTypes) || fortuneTypes.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Fortune types array is required'
      });
    }

    // Calculate total token cost
    let totalCost = 0;
    for (const type of fortuneTypes) {
      totalCost += tokenService['getTokenCostForCategory'](type);
    }

    // Check token balance
    const balance = await tokenService.getTokenBalance(userId);
    if (!balance.isUnlimited && balance.balance < totalCost) {
      return res.status(402).json({
        success: false,
        error: 'Insufficient tokens',
        required_tokens: totalCost,
        current_balance: balance.balance
      });
    }

    // Get user profile
    const { data: userProfile } = await supabaseAdmin
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (!userProfile) {
      return res.status(404).json({
        success: false,
        error: 'User profile not found'
      });
    }

    // Generate fortunes
    const results: Record<string, any> = {};
    const errors: Record<string, string> = {};
    let successCount = 0;

    for (const fortuneType of fortuneTypes) {
      try {
        // Deduct tokens for each fortune
        const deductionResult = await tokenService.deductTokens(userId, fortuneType);
        if (!deductionResult.success) {
          errors[fortuneType] = deductionResult.error || 'Token deduction failed';
          continue;
        }

        // Generate fortune
        const fortuneResult = await fortuneService.getOrCreateFortune(
          userId,
          fortuneType,
          userProfile
        );

        if (fortuneResult.success) {
          results[fortuneType] = fortuneResult.data;
          successCount++;
        } else {
          errors[fortuneType] = fortuneResult.error || 'Fortune generation failed';
          // Refund tokens on failure
          const cost = tokenService['getTokenCostForCategory'](fortuneType);
          await tokenService.addTokens(
            userId,
            cost,
            'refund',
            `Failed to generate ${fortuneType} fortune in batch`
          );
        }
      } catch (error) {
        logger.error(`Batch fortune error for ${fortuneType}:`, error);
        errors[fortuneType] = 'Internal error';
      }
    }

    // Get final balance
    const finalBalance = await tokenService.getTokenBalance(userId);

    return res.json({
      success: successCount > 0,
      data: {
        results,
        errors: Object.keys(errors).length > 0 ? errors : undefined,
        summary: {
          requested: fortuneTypes.length,
          successful: successCount,
          failed: fortuneTypes.length - successCount
        }
      },
      token_balance: finalBalance.balance,
      tokens_used: totalCost
    });

  } catch (error) {
    logger.error('Generate batch fortunes error:', error);
    next(error);
  }
};

// Get fortune history
export const getFortuneHistory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const { data, error, count } = await supabaseAdmin
      .from('fortune_history')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return res.json({
      success: true,
      data: data || [],
      pagination: {
        limit,
        offset,
        total: count || 0
      }
    });

  } catch (error) {
    logger.error('Get fortune history error:', error);
    next(error);
  }
};