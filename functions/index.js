const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// reservation_request에서 reservation으로 상태가 변경될 때 트리거
exports.sendNotificationOnReservation = functions.database
    .ref('/reservation/{category}/{equipment}/{date}/{time}')
    .onUpdate((change, context) => {
        const beforeData = change.before.val(); // 변경 전 데이터
        const afterData = change.after.val();   // 변경 후 데이터

        // 예약 상태가 변경되었는지 확인
        if (!beforeData && afterData) {
            const reservationData = afterData;  // 변경 후 데이터 (예약 정보)
            const category = context.params.category;
            const equipment = context.params.equipment;
            const date = context.params.date;
            const time = context.params.time;
            const uid = reservationData.uid;
            const times = reservationData.times; // 예약 시간

            // FCM 토큰을 가져오는 함수
            return getTokenFromUid(uid).then(userToken => {
                if (userToken) {
                    const payload = {
                        notification: {
                            title: `${category} 예약 승인`,
                            body: `${equipment}의 ${date} 날짜에 ${times[0]} 예약이 승인되었습니다.`,
                        },
                    };

                    // 사용자에게 푸시 알림 전송
                    return admin.messaging().sendToDevice(userToken, payload)
                        .then(response => {
                            console.log('FCM 푸시 알림 전송 성공:', response);
                        })
                        .catch(error => {
                            console.error('푸시 알림 전송 실패:', error);
                        });
                } else {
                    console.error('FCM 토큰을 찾을 수 없습니다.');
                    return null;
                }
            });
        } else {
            console.log('변경 사항이 없습니다.');
            return null;
        }
    });

// 예시: UID로 FCM 토큰을 가져오는 함수 (비동기 함수로 변경)
function getTokenFromUid(uid) {
    return admin.database().ref(`/users/${uid}/token`).once('value').then(snapshot => {
        return snapshot.val(); // FCM 토큰 반환
    });
}
