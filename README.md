# Digital_Watch_Multi_Sensor_Interface
<br>

## 프로젝트 개요
- 대한상공회의소 서울기술교육센터에서 진행한 FPGA 보드를 이용한 Digital Watch/Stopwatch + 초음파센서/온습도센서 Interface 컨트롤러입니다.
- FND와 버튼, UART를 이용하여 Watch/Stopwatch를 조정하고, Switch를 사용하여 네 가지 mode 변경이 가능합니다.
- 각 mode는 Switch[0],Switch[1]을 통해 이동 가능하며 Switch[2]를 통해 Watch/Stopwatch mode에서 분/초 display 선택할 수 있습니다.
- Swtich[15]를 통해 Enable할 수 있습니다.
  |Switch[1:0]|Mode|
  |:---------:|:--:|
  |00|Watch|
  |01|Stopwatch|
  |10|초음파 센서|
  |11|온습도 센서|
- 자세한 내용은 아래의 링크들을 참고해 주세요.
    - [Watch/Stopwatch + UART 중간 발표](https://github.com/yjm020500/Digital_Watch_Multi_Sensor_Interface/blob/main/Docs/group5_uart_project_%EC%A4%91%EA%B0%84%EB%B0%9C%ED%91%9C.pdf)
    - [Watch/Stopwatch + 온습도 센서와 초음파센서 + UART 최종 발표](https://github.com/yjm020500/Digital_Watch_Multi_Sensor_Interface/blob/main/Docs/5%EC%A1%B0_%EC%B5%9C%EC%A2%85%EB%B0%9C%ED%91%9C_%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8.pdf)
    - [DemoVideo](https://github.com/yjm020500/Digital_Watch_Multi_Sensor_Interface/tree/main/DemoVideo)

## 모듈 구성
1. Top module
    - Stopwatch/Watch, 온습도 센서, 초음파 센서, UART, FND, Button Detector가 포함된 top module입니다.
      <img width="1294" height="729" alt="image" src="https://github.com/user-attachments/assets/f9ff91f2-2aee-4ecc-82ac-1f93de5ede4d" />
2. Stopwatch
    - Stopwatch 기능을 수행하는 모듈입니다.
    - 분/초 값을 카운트하여 FND 출력합니다.
    - Button을 사용하여 RUN/STOP/CLEAR가 가능합니다.
3. Watch
    - Watch 기능을 수행하는 모듈입니다.
    - 분/초 값을 카운트하여 FND 출력합니다.
    - Up Count/Down Count 모두 가능합니다.
    - Button을 사용하여 Watch값을 Up/Down 가능합니다.
4. 온습도 센서
    - DHT11 온습도 센서를 사용하였습니다.
    - Interface를 통해 정해진 Protocol에 따라 온도와 습도 값을 받아 FND 출력합니다.
      <img width="637" height="228" alt="image" src="https://github.com/user-attachments/assets/cc98c524-888d-44f7-abdc-5a525ef3ae29" />
5. 초음파 센서
    - HC-SR04 초음파 센서를 사용합니다.
    - Interface를 통해 초음파가 되돌아오는 시간을 측정하여 거리를 계산한 후 FND 출력합니다.
      <img width="589" height="168" alt="image" src="https://github.com/user-attachments/assets/daf99b70-3ea7-4ad0-b76f-732e08669f94" />

6. UART
    - UART 통신을 담당합니다.
    - 설정한 Baudrate에 따라 PC와 통신합니다.
    - UART로 전송하는 각 신호

      |ASCII|세부 내용|
      |:---:|:------:|
      |G|Stopwatch 시작|
      |S|Stopwatch 정지|
      |C|Stopwatch clear|
      |U|Watch mode에서 선택된 값 상승<br>초음파/온습도 센서 mode에서 PC로 센서값 전송|
      |D|Watch mode에서 선택된 값 감소|
      |L|Watch mode에서 현재 선택된 자리의 왼쪽 자리 선택|
      |R|Watch mode에서 현재 선택된 자리의 오른쪽 자리 선택|
      |M|Mode 변경 Switch[0] 변경|
      |N|Mode 변경 Switch[1] 변경|
      |W|Watch/Stopwatch 분/초 변경|
      |E|Enable 값(Switch[15]) 변경|
      |ESC|Reset|

7. FND
    - 받은 데이터를 FND 출력하는 FND controller입니다.
    -  Switch[2]를 사용하여 Watch/Stopwatch mode에서 분/초 Display를 바꿀 수 있습니다.
8. Button Detector
    - Shift register를 사용하여 Debounced button signal을 1번 누를 때마다 1tick 신호로 변환합니다.

