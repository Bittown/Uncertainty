function PinKeeper(pin_txt,
                   pin_btn,
                   pin_path,
                   disable_on,
                   commit_title,
                   pin_title,
                   pin_counter_title) {
  this.pin_txt = pin_txt;
  this.pin_btn = pin_btn;
  this.PIN_PATH = pin_path;
  this.disable_on = disable_on;
  this.COMMIT_TITLE = commit_title;
  this.PIN_TITLE = pin_title;
  this.PIN_COUNTER_TITLE = pin_counter_title;
  this.pin_counter = 0;

  this.countPin = function () {
    if (!(this.pin_counter > 0)) {
      return;
    }

    --this.pin_counter;

    if(this.pin_btn.innerText !== this.COMMIT_TITLE) {
      if (this.pin_counter <= 0) {
        this.pin_btn.disabled = false;
        this.pin_btn.innerText = this.PIN_TITLE;
      } else {
        this.pin_btn.disabled = true;
        this.pin_btn.innerText = "" + this.pin_counter + this.PIN_COUNTER_TITLE;
      }
    }

    var keeper = this;
    setTimeout(function(){keeper.countPin();}, 1000);
  };

  this.transPinBtn2Commit = function () {
    this.pin_btn.innerText = this.COMMIT_TITLE;
    this.pin_btn.type = "commit";
    this.pin_btn.onclick = null;
  };

  this.initPinBtn = function () {
    this.pin_btn.innertext = this.PIN_TITLE;
    if (this.pin_btn.disabled) {
      return;
    }

    this.pin_btn.type = "button";
    var keeper = this;
    this.pin_btn.onclick = function(){
      ajaxDo("get", keeper.PIN_PATH, true);
      keeper.pin_counter = 60;
      keeper.countPin();
    };
  };

  this.updatePinBtn = function() {
    const has_pin = this.pin_txt.value !== "";
    this.pin_btn.innerText = has_pin ? this.COMMIT_TITLE : this.PIN_TITLE;
    this.pin_btn.disabled = this.disable_on() || (!has_pin && this.pin_counter > 0);
    if (this.pin_btn.disabled) {
      return;
    }

    if (has_pin) {
      this.transPinBtn2Commit();
    } else {
      this.initPinBtn();
    }
  };

  this.updatePinBtn();
}
