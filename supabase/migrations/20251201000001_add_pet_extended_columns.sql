-- Add extended columns to pets table for enhanced pet fortune feature
-- These columns support richer pet profile data for LLM-based fortune generation

-- Gender column (수컷/암컷/모름)
ALTER TABLE pets
ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT '모름';

-- Breed column (품종 - 말티즈, 러시안블루 등)
ALTER TABLE pets
ADD COLUMN IF NOT EXISTS breed TEXT;

-- Personality column (성격 - 활발함, 차분함, 수줍음 등)
ALTER TABLE pets
ADD COLUMN IF NOT EXISTS personality TEXT;

-- Health notes column (건강 특이사항)
ALTER TABLE pets
ADD COLUMN IF NOT EXISTS health_notes TEXT;

-- Neutered status column (중성화 여부)
ALTER TABLE pets
ADD COLUMN IF NOT EXISTS is_neutered BOOLEAN;

-- Add comments for clarity
COMMENT ON COLUMN pets.gender IS 'Pet gender: 수컷, 암컷, or 모름';
COMMENT ON COLUMN pets.breed IS 'Pet breed (e.g., 말티즈, 러시안블루)';
COMMENT ON COLUMN pets.personality IS 'Pet personality trait (e.g., 활발함, 차분함)';
COMMENT ON COLUMN pets.health_notes IS 'Health notes and special conditions';
COMMENT ON COLUMN pets.is_neutered IS 'Whether the pet is neutered/spayed';
