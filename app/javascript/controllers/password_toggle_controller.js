import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-toggle"
export default class extends Controller {
  static targets = ["passwordField", "toggleButton"];

  connect() {
  }

  toggleVisibility() {
    const passwordField = this.passwordFieldTarget;
    const toggleButton = this.toggleButtonTarget;
    const isPasswordShown = passwordField.type === "text";

    passwordField.type = isPasswordShown ? "password" : "text";
    toggleButton.classList.toggle("active", isPasswordShown);
  }
}
