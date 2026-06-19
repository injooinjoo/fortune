// global-setup.js
module.exports = async config => {
  console.log('🔧 [PLAYWRIGHT] Global setup started');

  // Set test environment variables
  process.env.TEST_MODE = 'true';
  process.env.BYPASS_AUTH = 'true';

  console.log('🔧 [PLAYWRIGHT] Test environment variables set');

  // Optional: Pre-create test account in database
  // This could be done here if needed

  console.log('🔧 [PLAYWRIGHT] Global setup completed');
};
