// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import jQuery from 'jquery'
window.jQuery = jQuery
window.$ = jQuery

import "./controllers"
import * as bootstrap from "bootstrap"
// Make bootstrap globally available
window.bootstrap = bootstrap

import "./nice_admin"
import "boxicons"

import "chartkick/chart.js"
import "chartjs-plugin-annotation"
