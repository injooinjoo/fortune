
# TestSprite AI Testing Report(MCP)

---

## 1️⃣ Document Metadata
- **Project Name:** fortune
- **Date:** 2025-12-16
- **Prepared by:** TestSprite AI Team

---

## 2️⃣ Requirement Validation Summary

#### Test TC001
- **Test Name:** OAuth Login Success for Each Provider
- **Test Code:** [TC001_OAuth_Login_Success_for_Each_Provider.py](./TC001_OAuth_Login_Success_for_Each_Provider.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A02C3C00BC1B0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&wgl=1&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171164&bpp=20&bdt=4574&idt=963&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=6316744361849&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31096041%2C95376242%2C95378600%2C95378750%2C95344788%2C95340252%2C95340254&oid=2&pvsid=419537813537992&tmod=1458685781&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&plas=404x992_l%7C404x992_r&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1002:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0C4DD00BC1B0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/3289ba99-af1c-44f1-9d27-a28caa78c519
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC002
- **Test Name:** Email/Password Signup and Login Flow
- **Test Code:** [TC002_EmailPassword_Signup_and_Login_Flow.py](./TC002_EmailPassword_Signup_and_Login_Flow.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A098420064000000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&wgl=1&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823170983&bpp=20&bdt=4221&idt=992&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=4879599376266&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095746%2C31095903%2C31096041%2C42531706%2C95376241%2C95378600%2C95378750%2C95379212%2C95379651%2C42533293%2C95377245&oid=2&pvsid=8312851514199913&tmod=345252092&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&plas=404x992_l%7C404x992_r&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1039:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0ACE71964000000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/1e7f7442-4580-4246-aad0-6780cf382797
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC003
- **Test Name:** User Onboarding Profile Input Validation and Saving
- **Test Code:** [TC003_User_Onboarding_Profile_Input_Validation_and_Saving.py](./TC003_User_Onboarding_Profile_Input_Validation_and_Saving.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0AC4200641E0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&wgl=1&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171149&bpp=17&bdt=4579&idt=969&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=4062095091361&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31096041%2C95376242%2C95376583%2C95378749%2C95379902&oid=2&pvsid=1736772241371322&tmod=1801080412&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1010:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[ERROR] [Report Only] Refused to frame 'https://www.google.com/' because an ancestor violates the following Content Security Policy directive: "frame-ancestors 'self'".
 (at :0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A018BF19641E0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/c20d82ac-e119-4822-8eab-611658ab2aaa
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC004
- **Test Name:** Home Dashboard Cards Rendering and Swipe Functionality
- **Test Code:** [TC004_Home_Dashboard_Cards_Rendering_and_Swipe_Functionality.py](./TC004_Home_Dashboard_Cards_Rendering_and_Swipe_Functionality.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A08439009C360000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171149&bpp=24&bdt=4385&idt=972&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=5290809740093&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31096042%2C95376241%2C95376582%2C95378599%2C95378750%2C42533294%2C95344788&oid=2&pvsid=3394719475016005&tmod=762595270&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1015:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/0673c017-1bb7-4b28-95dc-22514aa76b89
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC005
- **Test Name:** Fortune Input Validation and AI Result Generation Performance
- **Test Code:** [TC005_Fortune_Input_Validation_and_AI_Result_Generation_Performance.py](./TC005_Fortune_Input_Validation_and_AI_Result_Generation_Performance.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0983C00A4100000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171153&bpp=20&bdt=4398&idt=1080&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=3466422691987&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095903%2C31096042%2C95376241%2C95378750%2C42533293%2C95344791&oid=2&pvsid=6147889431456361&tmod=1557831102&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1144:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A098D617A4100000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06CD617A4100000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0D85616A4100000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/c5ef5c59-6f81-45d1-b0f5-a9ea91c68e84
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC006
- **Test Name:** Premium Content Access and In-App Purchase Flow
- **Test Code:** [TC006_Premium_Content_Access_and_In_App_Purchase_Flow.py](./TC006_Premium_Content_Access_and_In_App_Purchase_Flow.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0C43B004C320000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171168&bpp=23&bdt=4403&idt=1025&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=2609793162481&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095904%2C31096042%2C95376242%2C95376582%2C95378750%2C95379215%2C95380019%2C42533294&oid=2&pvsid=1936832134845480&tmod=1640096867&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1070:0:0)
[ERROR] Failed to load resource: net::ERR_CONTENT_LENGTH_MISMATCH (at http://localhost:3000/packages/fortune/core/components/app_card.dart.lib.js:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A084ED174C320000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/f70138e0-4b17-4b0b-8dcd-cfea91b58520
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC007
- **Test Name:** Profile Management Edit and Data Persistence
- **Test Code:** [TC007_Profile_Management_Edit_and_Data_Persistence.py](./TC007_Profile_Management_Edit_and_Data_Persistence.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06C4400AC0A0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171149&bpp=17&bdt=4550&idt=976&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=4591883600956&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095904%2C31096042%2C95376242%2C95378749%2C95344789&oid=2&pvsid=2027091837155338&tmod=510480343&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1020:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0C48517AC0A0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/24982546-69b1-4215-b9b2-0ee700497f6f
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC008
- **Test Name:** Error Handling on API Failures and Input Errors
- **Test Code:** [TC008_Error_Handling_on_API_Failures_and_Input_Errors.py](./TC008_Error_Handling_on_API_Failures_and_Input_Errors.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06C440084340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&wgl=1&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171504&bpp=20&bdt=4732&idt=932&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=2853638579350&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095746%2C31096041%2C95376242%2C95378600%2C95378750%2C95379034%2C95379058&oid=2&pvsid=1729547001452148&tmod=1844488899&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&plas=404x992_l%7C404x992_r&bz=1&ifi=1&uci=a!1&fsb=1&dtd=994:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06C440084340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/a5d56325-8646-4a4a-8cb0-25377fd67670
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC009
- **Test Name:** Security Validation for OAuth, Payments, and Data Protection
- **Test Code:** [TC009_Security_Validation_for_OAuth_Payments_and_Data_Protection.py](./TC009_Security_Validation_for_OAuth_Payments_and_Data_Protection.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0183B00DC0F0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171154&bpp=20&bdt=4389&idt=976&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=2917473725515&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31093848%2C31095904%2C31096042%2C95376241%2C95378600%2C95378750%2C95379484%2C95379897%2C95344788&oid=2&pvsid=4683072848686912&tmod=1376408520&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&plas=404x992_l%7C404x992_r&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1023:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A018DB00DC0F0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0443B00DC0F0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0ECF50DDC0F0000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/44a76436-4a4e-4ef1-bb7d-9fa869787cce
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC010
- **Test Name:** Performance Testing: Launch Time and Fortune Generation
- **Test Code:** [TC010_Performance_Testing_Launch_Time_and_Fortune_Generation.py](./TC010_Performance_Testing_Launch_Time_and_Fortune_Generation.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A098420064110000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171150&bpp=20&bdt=4387&idt=962&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=8621383389285&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095904%2C31096042%2C95376242%2C95378749%2C95344788&oid=2&pvsid=7130438048780964&tmod=324071824&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1001:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0C42A1A64110000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/41e86789-bd63-43de-b011-0c6bcac54f02
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC011
- **Test Name:** Navigation and Deep Link Functionality
- **Test Code:** [TC011_Navigation_and_Deep_Link_Functionality.py](./TC011_Navigation_and_Deep_Link_Functionality.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A09840006C340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171262&bpp=17&bdt=4495&idt=976&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=2490530821051&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31096042%2C95376242%2C95378600%2C95378749%2C95379214%2C95344787%2C95377245&oid=2&pvsid=4826710714665720&tmod=1815724343&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&plas=404x992_l%7C404x992_r&bz=1&ifi=1&uci=a!1&fsb=1&dtd=1025:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06C40006C340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0AC27166C340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A06C40006C340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/3d57571b-09ac-49e9-ae9e-d735bd115616
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---

#### Test TC012
- **Test Name:** Interactive Features Accessibility and Functionality
- **Test Code:** [TC012_Interactive_Features_Accessibility_and_Functionality.py](./TC012_Interactive_Features_Accessibility_and_Functionality.py)
- **Test Error:** 
Browser Console Logs:
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0044500C4340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at http://localhost:3000/:0:0)
[WARNING] An iframe which has both allow-scripts and allow-same-origin for its sandbox attribute can escape its sandboxing. (at https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-YOUR_ADSENSE_CLIENT_ID&output=html&adk=1812271804&adf=3025194257&lmt=1765823172&plat=1%3A16777216%2C2%3A16777216%2C3%3A16%2C4%3A16%2C9%3A32776%2C16%3A8388608%2C17%3A32%2C24%3A32%2C25%3A32%2C30%3A1081344%2C32%3A32%2C41%3A32%2C42%3A32&format=0x0&url=http%3A%2F%2Flocalhost%3A3000%2F&pra=5&asro=0&aiapm=0.1542&aiapmd=0.1423&aiapmi=0.16&aiapmid=1&aiact=0.5423&aiactd=0.7&aicct=0.7&aicctd=0.5799&ailct=0.5849&ailctd=0.65&aimart=4&aimartd=4&aieuf=1&aicrs=1&uach=WyJXaW5kb3dzIiwiMTAuMCIsIng2NCIsIiIsIjEzNC4wLjY5OTguMzUiLG51bGwsMCxudWxsLCI2NCIsW1siQ2hyb21pdW0iLCIxMzQuMC42OTk4LjM1Il0sWyJOb3Q6QS1CcmFuZCIsIjI0LjAuMC4wIl0sWyJIZWFkbGVzc0Nocm9tZSIsIjEzNC4wLjY5OTguMzUiXV0sMF0.&abgtt=6&dt=1765823171329&bpp=23&bdt=4558&idt=797&shv=r20251211&mjsv=m202512100101&ptt=9&saldr=aa&abxe=1&cookie_enabled=1&eoidce=1&nras=1&correlator=4789924387555&frm=20&pv=2&u_tz=0&u_his=2&u_h=1100&u_w=1280&u_ah=1100&u_aw=1280&u_cd=24&u_sd=1&dmc=4&adx=-12245933&ady=-12245933&biw=1280&bih=1100&scr_x=0&scr_y=0&eid=31095903%2C31096042%2C95376242%2C95376582%2C95378599%2C95378750%2C95379902%2C95344788&oid=2&pvsid=1905814200605060&tmod=640030627&uas=0&nvt=1&fsapi=1&fc=1920&brdim=0%2C0%2C0%2C0%2C1280%2C0%2C1280%2C1100%2C1280%2C1100&vis=1&rsz=%7C%7Cs%7C&abl=NS&fu=32768&bc=31&bz=1&ifi=1&uci=a!1&fsb=1&dtd=888:0:0)
[WARNING] window.flutterWebRenderer is now deprecated.
Use engineInitializer.initializeEngine(config) instead.
See: https://docs.flutter.dev/development/platform-integration/web/initialization (at http://localhost:3000/dart_sdk.js:235718:17)
[WARNING] [GroupMarkerNotSet(crbug.com/242999)!:A0EC7815C4340000]Automatic fallback to software WebGL has been deprecated. Please use the --enable-unsafe-swiftshader flag to opt in to lower security guarantees for trusted content. (at https://ep2.adtrafficquality.google/sodar/sodar2/237/runner.html:0:0)
[WARNING] Found an existing <meta name="viewport"> tag. Flutter Web uses its own viewport configuration for better compatibility with Flutter. This tag will be replaced. (at http://localhost:3000/dart_sdk.js:235718:17)
- **Test Visualization and Result:** https://www.testsprite.com/dashboard/mcp/tests/31834e83-53b6-4d0e-9f83-590f25a1332f/0b643efe-bde0-4cbd-849b-1541efccc0c3
- **Status:** ❌ Failed
- **Analysis / Findings:** {{TODO:AI_ANALYSIS}}.
---


## 3️⃣ Coverage & Matching Metrics

- **0.00** of tests passed

| Requirement        | Total Tests | ✅ Passed | ❌ Failed  |
|--------------------|-------------|-----------|------------|
| ...                | ...         | ...       | ...        |
---


## 4️⃣ Key Gaps / Risks
{AI_GNERATED_KET_GAPS_AND_RISKS}
---