const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// reservation 경로 아래의 3D Printer나 laser cutter의 예약 추가 감지
exports.sendNotificationOnReservation = functions.database.ref('/reservation/{category}/{equipment}/{date}/{time}')
    .onCreate((snapshot, context) => {
        const reservationData = snapshot.val();  // 예약 데이터
        const category = context.params.category;  // 예: '3D Printer', 'laser cutter'
        const equipment = context.params.equipment;  // 예: 장비명 (S4 등)
        const date = context.params.date;  // 예: 2024-09-04
        const time = context.params.time;  // 예: 시간 (16:00 - 21:00)
        const uid = reservationData.uid;  // 예약한 사용자의 UID
        const times = reservationData.times;  // 예: ["16:00 - 17:00", ...]

        // 이 uid로 FCM 토큰을 찾는 로직이 필요합니다.
        // FCM 토큰이 데이터베이스에 별도로 저장되어 있다고 가정.
        const userToken = getTokenFromUid(uid);  // FCM 토큰을 가져오는 함수

        const payload = {
            notification: {
                title: `${category} 예약 승인`,
                body: `${equipment}의 ${date} 날짜에 ${times[0]} 예약이 승인되었습니다.`
            }
        };

        // 사용자에게 FCM 푸시 알림 전송
        return admin.messaging().sendToDevice(userToken, payload)
            .then(response => {
                console.log('FCM 푸시 알림 전송 성공:', response);
            })
            .catch(error => {
                console.error('푸시 알림 전송 실패:', error);
            });
    });

// 예시: UID로 FCM 토큰을 가져오는 함수 (데이터베이스에서 찾는다고 가정)
function getTokenFromUid(uid) {
    // 예를 들어 /users/{uid}/token에 FCM 토큰이 있다고 가정.
    return admin.database().ref(`/users/${uid}/token`).once('value').then(snapshot => {
        return snapshot.val();  // FCM 토큰 반환
    });
}
