import { LegalScreen } from '../src/screens/legal-screen';

// 전자상거래법 제13조(사업자 정보 표기 의무) 대응.
// 실제 사업자등록 정보는 프로덕션 배포 전 반드시 채워 넣어야 함.
// "기재 예정" 항목은 법적 고지 무효 사유가 되므로 공백 상태로 스토어 심사 금지.

export default function BusinessInfoRoute() {
  return (
    <LegalScreen
      path="/business-info"
      title="사업자 정보"
      summary="전자상거래법에 따른 사업자 표시 정보입니다."
      sections={[
        {
          title: '사업자 기본 정보',
          body:
            '상호: 비욘드 (Beyond)\n' +
            '서비스명: 온도 (Ondo)\n' +
            '대표자: 김인주\n' +
            '사업자등록번호: 552-20-02389\n' +
            '사업장 소재지: 서울특별시 서초구',
        },
        {
          title: '연락처',
          body:
            '고객센터 이메일: injooinjoo@gmail.com\n' +
            '개인정보 관련 문의: injooinjoo@gmail.com\n' +
            '운영 시간: 평일 10:00~18:00 (주말·공휴일 휴무)\n' +
            '회신 기준: 영업일 기준 7일 이내',
        },
        {
          title: '청소년 보호 책임자',
          body:
            '정보통신망법 및 청소년보호법에 따라 청소년 유해 정보를 통제하고 이용자 신고를 관리하는 책임자입니다.\n\n' +
            '성명: 김인주\n' +
            '이메일: injooinjoo@gmail.com',
        },
        {
          title: '관련 링크',
          body:
            '- 이용약관: /terms-of-service\n' +
            '- 개인정보처리방침: /privacy-policy\n' +
            '- 사용자 라이선스(EULA): /eula\n' +
            '- 면책 조항: /disclaimer\n' +
            '- 오픈소스 라이선스: /open-source-licenses',
        },
      ]}
    />
  );
}
