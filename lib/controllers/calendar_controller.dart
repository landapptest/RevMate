class CalendarController {
  DateTime displayedDate;

  CalendarController(this.displayedDate);

  void goToPreviousMonth() {
    displayedDate = DateTime(displayedDate.year, displayedDate.month - 1);
  }

  void goToNextMonth() {
    displayedDate = DateTime(displayedDate.year, displayedDate.month + 1);
  }
}
