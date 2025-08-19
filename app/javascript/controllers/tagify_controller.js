import { Controller } from "@hotwired/stimulus"
import Tagify from '@yaireo/tagify'

// Connects to data-controller="tagify"
export default class extends Controller {
  static values = {
    csv: String
  }

  connect() {
    console.log('Tagify controller connected');
    this.initializeTagify();
  }

  initializeTagify() {
    this.tagify = new Tagify(this.element, {
      delimiters: ",",
      duplicates: false,
      placeholder: "Enter keywords separated by commas",
      dropdown: {
        enabled: 0
      }
    });

    if (this.csvValue) {
      const tagifyData = this.csvValue.split(',').map(value => ({ value: value.trim() }));
      this.tagify.addTags(tagifyData);
    }

    this.element.closest('form').addEventListener('submit', this.handleSubmit.bind(this));
  }

  handleSubmit(event) {
    event.preventDefault();
    const csvData = this.tagify.value.map(tag => tag.value).join(',');
    this.element.value = csvData;
    event.target.submit();
  }

  disconnect() {
    this.tagify.destroy();
  }
}
