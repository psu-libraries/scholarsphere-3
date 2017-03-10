// Overrides Sufia checklist_item.es6 to add text for screen readers when metadata requirements are complete.

export class ChecklistItem {
  constructor(element) {
    this.element = element
  }

  check() {
    this.element.removeClass('incomplete')
    this.element.addClass('complete')
    this.element.children('a').text(this.element.data("complete"))
  }

  uncheck() {
    this.element.removeClass('complete')
    this.element.addClass('incomplete')
    this.element.children('a').text(this.element.data("incomplete"))
  }
}
