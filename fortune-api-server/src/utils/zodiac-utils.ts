// 서양 별자리 계산
export function calculateZodiacSign(birthDate: string): string {
  const date = new Date(birthDate);
  const month = date.getMonth() + 1;
  const day = date.getDate();

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return 'aries';
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return 'taurus';
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return 'gemini';
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return 'cancer';
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return 'leo';
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return 'virgo';
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return 'libra';
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return 'scorpio';
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return 'sagittarius';
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return 'capricorn';
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return 'aquarius';
  if ((month === 2 && day >= 19) || (month === 3 && day <= 20)) return 'pisces';

  return 'unknown';
}

// 동양 띠 계산
export function calculateChineseZodiac(birthDate: string): string {
  const year = new Date(birthDate).getFullYear();
  const zodiacAnimals = [
    'rat', 'ox', 'tiger', 'rabbit', 'dragon', 'snake',
    'horse', 'goat', 'monkey', 'rooster', 'dog', 'pig'
  ];
  
  // 1900년이 rat년이므로 이를 기준으로 계산
  const baseYear = 1900;
  const index = (year - baseYear) % 12;
  
  return zodiacAnimals[index >= 0 ? index : index + 12];
}

// 한국어 별자리 이름
export const zodiacSignsKorean: Record<string, string> = {
  aries: '양자리',
  taurus: '황소자리',
  gemini: '쌍둥이자리',
  cancer: '게자리',
  leo: '사자자리',
  virgo: '처녀자리',
  libra: '천칭자리',
  scorpio: '전갈자리',
  sagittarius: '사수자리',
  capricorn: '염소자리',
  aquarius: '물병자리',
  pisces: '물고기자리',
};

// 한국어 띠 이름
export const chineseZodiacKorean: Record<string, string> = {
  rat: '쥐띠',
  ox: '소띠',
  tiger: '호랑이띠',
  rabbit: '토끼띠',
  dragon: '용띠',
  snake: '뱀띠',
  horse: '말띠',
  goat: '양띠',
  monkey: '원숭이띠',
  rooster: '닭띠',
  dog: '개띠',
  pig: '돼지띠',
};