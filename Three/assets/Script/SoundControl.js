cc.Class({
    extends: cc.Component,

    properties: {
        buttonSound: {
            type: cc.AudioSource,
            default: null
        },
        explosionSound: {
            type: cc.AudioSource,
            default: null
        },
        dropSound: {
            type: cc.AudioSource,
            default: null
        },
        bgMusic: {
            type: cc.AudioSource,
            default: null
        }
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start() {
        this.musicOn = true;
        this.soundOn = true;
    },
    setMusicOnoff() {
        this.musicOn = !this.musicOn;
        if (this.musicOn) {
            this.allMusicStart();
        } else {
            this.allMusicPause();
        }
    },
    playDrop() {
        if (this.soundOn) {
            this.dropSound.play();
        }
    },
    playExp() {
        if (this.soundOn) {
            this.explosionSound.play();
        }
    },
    playButton() {
        if (this.soundOn) {
            this.buttonSound.play();
        }
    },
    setSoundOnoff() {
        this.soundOn = !this.soundOn;
    },
    allSoundPause() {
        this.buttonSound.pause();
        this.explosionSound.pause();
        this.dropSound.pause();
    },
    allMusicPause() {
        this.bgMusic.pause();
    },
    allMusicStart() {
        this.bgMusic.play();
    }
    // update (dt) {},
});
