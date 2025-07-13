import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.middleware';
import { tokenGuardMiddleware } from '../middleware/tokenGuard.middleware';
import * as fortuneController from '../controllers/fortune.controller';

const router = Router();

// Apply auth middleware to all fortune routes
router.use(authMiddleware);

// Basic fortune endpoints
router.post('/daily', tokenGuardMiddleware, fortuneController.getDailyFortune);
router.post('/today', tokenGuardMiddleware, fortuneController.getTodayFortune);
router.post('/tomorrow', tokenGuardMiddleware, fortuneController.getTomorrowFortune);
router.post('/weekly', tokenGuardMiddleware, fortuneController.getWeeklyFortune);
router.post('/monthly', tokenGuardMiddleware, fortuneController.getMonthlyFortune);
router.post('/yearly', tokenGuardMiddleware, fortuneController.getYearlyFortune);
router.post('/hourly', tokenGuardMiddleware, fortuneController.getHourlyFortune);

// Traditional fortune endpoints
router.post('/saju', tokenGuardMiddleware, fortuneController.getSajuFortune);
router.post('/traditional-saju', tokenGuardMiddleware, fortuneController.getTraditionalSajuFortune);
router.post('/saju-psychology', tokenGuardMiddleware, fortuneController.getSajuPsychologyFortune);
router.post('/tojeong', tokenGuardMiddleware, fortuneController.getTojeongFortune);
router.post('/salpuli', tokenGuardMiddleware, fortuneController.getSalpuliFortune);
router.post('/palmistry', tokenGuardMiddleware, fortuneController.getPalmistryFortune);
router.post('/physiognomy', tokenGuardMiddleware, fortuneController.getPhysiognomyFortune);

// Personality fortune endpoints
router.post('/mbti', tokenGuardMiddleware, fortuneController.getMbtiFortune);
router.post('/personality', tokenGuardMiddleware, fortuneController.getPersonalityFortune);
router.post('/blood-type', tokenGuardMiddleware, fortuneController.getBloodTypeFortune);

// Love & relationship fortune endpoints
router.post('/love', tokenGuardMiddleware, fortuneController.getLoveFortune);
router.post('/marriage', tokenGuardMiddleware, fortuneController.getMarriageFortune);
router.post('/compatibility', tokenGuardMiddleware, fortuneController.getCompatibilityFortune);
router.post('/traditional-compatibility', tokenGuardMiddleware, fortuneController.getTraditionalCompatibilityFortune);
router.post('/couple-match', tokenGuardMiddleware, fortuneController.getCoupleMatchFortune);
router.post('/blind-date', tokenGuardMiddleware, fortuneController.getBlindDateFortune);
router.post('/ex-lover', tokenGuardMiddleware, fortuneController.getExLoverFortune);
router.post('/celebrity-match', tokenGuardMiddleware, fortuneController.getCelebrityMatchFortune);
router.post('/chemistry', tokenGuardMiddleware, fortuneController.getChemistryFortune);

// Career & business fortune endpoints
router.post('/career', tokenGuardMiddleware, fortuneController.getCareerFortune);
router.post('/employment', tokenGuardMiddleware, fortuneController.getEmploymentFortune);
router.post('/business', tokenGuardMiddleware, fortuneController.getBusinessFortune);
router.post('/startup', tokenGuardMiddleware, fortuneController.getStartupFortune);
router.post('/lucky-job', tokenGuardMiddleware, fortuneController.getLuckyJobFortune);

// Wealth & investment fortune endpoints
router.post('/wealth', tokenGuardMiddleware, fortuneController.getWealthFortune);
router.post('/lucky-investment', tokenGuardMiddleware, fortuneController.getLuckyInvestmentFortune);
router.post('/lucky-realestate', tokenGuardMiddleware, fortuneController.getLuckyRealEstateFortune);
router.post('/lucky-sidejob', tokenGuardMiddleware, fortuneController.getLuckySideJobFortune);

// Health & lifestyle fortune endpoints
router.post('/biorhythm', tokenGuardMiddleware, fortuneController.getBiorhythmFortune);
router.post('/moving', tokenGuardMiddleware, fortuneController.getMovingFortune);
router.post('/moving-date', tokenGuardMiddleware, fortuneController.getMovingDateFortune);
router.post('/avoid-people', tokenGuardMiddleware, fortuneController.getAvoidPeopleFortune);

// Sports & activity fortune endpoints
router.post('/lucky-hiking', tokenGuardMiddleware, fortuneController.getLuckyHikingFortune);
router.post('/lucky-cycling', tokenGuardMiddleware, fortuneController.getLuckyCyclingFortune);
router.post('/lucky-running', tokenGuardMiddleware, fortuneController.getLuckyRunningFortune);
router.post('/lucky-swim', tokenGuardMiddleware, fortuneController.getLuckySwimFortune);
router.post('/lucky-tennis', tokenGuardMiddleware, fortuneController.getLuckyTennisFortune);
router.post('/lucky-golf', tokenGuardMiddleware, fortuneController.getLuckyGolfFortune);
router.post('/lucky-baseball', tokenGuardMiddleware, fortuneController.getLuckyBaseballFortune);
router.post('/lucky-fishing', tokenGuardMiddleware, fortuneController.getLuckyFishingFortune);

// Lucky items fortune endpoints
router.post('/lucky-color', tokenGuardMiddleware, fortuneController.getLuckyColorFortune);
router.post('/lucky-number', tokenGuardMiddleware, fortuneController.getLuckyNumberFortune);
router.post('/lucky-items', tokenGuardMiddleware, fortuneController.getLuckyItemsFortune);
router.post('/lucky-outfit', tokenGuardMiddleware, fortuneController.getLuckyOutfitFortune);
router.post('/lucky-food', tokenGuardMiddleware, fortuneController.getLuckyFoodFortune);
router.post('/lucky-exam', tokenGuardMiddleware, fortuneController.getLuckyExamFortune);
router.post('/talisman', tokenGuardMiddleware, fortuneController.getTalismanFortune);

// Special fortune endpoints
router.post('/zodiac', tokenGuardMiddleware, fortuneController.getZodiacFortune);
router.post('/zodiac-animal', tokenGuardMiddleware, fortuneController.getZodiacAnimalFortune);
router.post('/birth-season', tokenGuardMiddleware, fortuneController.getBirthSeasonFortune);
router.post('/birthstone', tokenGuardMiddleware, fortuneController.getBirthstoneFortune);
router.post('/birthdate', tokenGuardMiddleware, fortuneController.getBirthdateFortune);
router.post('/past-life', tokenGuardMiddleware, fortuneController.getPastLifeFortune);
router.post('/new-year', tokenGuardMiddleware, fortuneController.getNewYearFortune);
router.post('/talent', tokenGuardMiddleware, fortuneController.getTalentFortune);
router.post('/five-blessings', tokenGuardMiddleware, fortuneController.getFiveBlessingsFortune);
router.post('/network-report', tokenGuardMiddleware, fortuneController.getNetworkReportFortune);
router.post('/timeline', tokenGuardMiddleware, fortuneController.getTimelineFortune);
router.post('/wish', tokenGuardMiddleware, fortuneController.getWishFortune);
router.post('/destiny', tokenGuardMiddleware, fortuneController.getDestinyFortune);
router.post('/celebrity', tokenGuardMiddleware, fortuneController.getCelebrityFortune);
router.post('/lucky-series', tokenGuardMiddleware, fortuneController.getLuckySeriesFortune);

// Utility endpoints
router.post('/generate', tokenGuardMiddleware, fortuneController.generateFortune);
router.post('/generate-batch', tokenGuardMiddleware, fortuneController.generateBatchFortune);
router.get('/history', fortuneController.getFortuneHistory);

// Dynamic category route (must be last)
router.post('/:category', tokenGuardMiddleware, fortuneController.getFortuneByCategory);

export default router;