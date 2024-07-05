window.addEventListener('message', (event) => {
    if (event.data.action == "notify") {
        notification(event.data.header, event.data.message, event.data.playerName, event.data.color, event.data.time);
    }
})

var sound = new Audio('notification.mp3');
sound.volume = 0.25;

notification = (header, message, playerName, color, time) => {
    const notification = $(`
        <div class="notify-container notify" style="background:${color}">
            <span id="notify-title">${header}</span><br>
            <span id="notify-text">${message}</span><br>
            <span id="notify-sender">${playerName}</span>
        </div>
    `).appendTo(`#notify-wrapper`);

    notification.fadeIn("slow");
    sound.play();

    setTimeout(() => {
        notification.css("animation-name", "bottomToTop")
        notification.fadeOut("slow");
    }, time);

    return notification;
}