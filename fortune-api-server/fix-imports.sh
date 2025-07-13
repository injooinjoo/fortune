#!/bin/bash

# Fix logger imports
find src -name "*.ts" -type f -exec sed -i '' "s/import { logger } from '\(.*\)\/logger';/import logger from '\1\/logger';/g" {} +
find src -name "*.ts" -type f -exec sed -i '' 's/import { logger } from "\(.*\)\/logger";/import logger from "\1\/logger";/g' {} +

# Fix supabaseAdmin import errors
find src -name "*.ts" -type f -exec sed -i '' 's/supabaseAdminAdmin/supabaseAdmin/g' {} +
find src -name "*.ts" -type f -exec sed -i '' "s/from '\.\.\/config\/supabaseAdmin'/from '..\/config\/supabase'/g" {} +
find src -name "*.ts" -type f -exec sed -i '' 's/from "\.\.\/config\/supabaseAdmin"/from "..\/config\/supabase"/g' {} +

echo "Import fixes applied!"