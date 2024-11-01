const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyOnReservationCompletion = functions.database
  .ref("/reservation_request/{requestId}")
  .onDelete((snapshot, context) => {
    const requestId = context.params.requestId;
    console.log(`예약 ID ${requestId} 삭제 감지`);

    const payload = {
      notification: {
        title: "예약이 완료되었습니다",
        body: `예약 ID ${requestId}이(가) 완료되었습니다. 확인해 주세요.`,
      },
    };

    return admin
      .database()
      .ref(`/users/`)
      .once("value")
      .then((snapshot) => {
        console.log("유저 데이터 로드 성공");
        const tokens = [];
        snapshot.forEach((childSnapshot) => {
          const token = childSnapshot.val().token;
          console.log(`찾은 토큰: ${token}`);
          if (token) {
            tokens.push(token);
          }
        });
        const uniqueTokens = [...new Set(tokens)]; // 중복 토큰 제거
        console.log(`FCM 토큰들 (중복 제거됨): ${uniqueTokens}`);
        return uniqueTokens;
      })
      .then((uniqueTokens) => {
        if (uniqueTokens.length > 0) {
          console.log("푸시 알림 전송 시도 중");

          // 개별적으로 `send` 메서드를 사용하여 각 토큰에 알림 전송
          const sendPromises = uniqueTokens.map((token) => {
            const message = {
              token: token,
              notification: payload.notification,
            };

            return admin.messaging().send(message)
              .then((response) => {
                console.log(`토큰 ${token} 전송 성공:`, response);
                return response;
              })
              .catch((error) => {
                console.error(`토큰 ${token} 전송 실패:`, error);
              });
          });

          // 모든 알림 전송이 완료될 때까지 기다림
          return Promise.all(sendPromises)
            .then((responses) => {
              console.log("모든 푸시 알림 전송 완료:", responses);
              return responses;
            })
            .catch((error) => {
              console.error("푸시 알림 전송 중 오류 발생:", error);
            });
        }
        console.log("토큰이 없어서 알림을 전송하지 않음");
        return null;
      })
      .catch((error) => {
        console.error("토큰 가져오기 실패:", error);
      });
  });
