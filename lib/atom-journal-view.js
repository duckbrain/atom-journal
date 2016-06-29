'use strict';

module.exports = (function() {
  var moment = require('moment');

  function AtomJournalView(serializedState) {
    var calendar, calendarCol, controls, day, dows, dowsRow, header, nextMonth, previousMonth, row;
    this.element = document.createElement('div');
    this.element.classList.add('atom-journal');
    this.days = [];
    dows = ['S', 'M', 'T', 'W', 'R', 'F', 'S'];
    calendarCol = document.createElement('div');
    controls = document.createElement('div');
    this.monthDisplay = document.createElement('span');
    previousMonth = document.createElement('a');
    nextMonth = document.createElement('a');
    calendar = document.createElement('div');
    dowsRow = document.createElement('div');
    calendarCol.classList.add('atom-journal-calendar-container');
    calendar.classList.add('atom-journal-calendar');
    dowsRow.classList.add('atom-journal-calendar-row');
    dowsRow.classList.add('atom-journal-calendar-header');
    controls.classList.add('atom-journal-calendar-controls');
    previousMonth.textContent = '<';
    nextMonth.textContent = '>';
    previousMonth.addEventListener('click', e=>this.onPreviousMonthClick(e));
    nextMonth.addEventListener('click', e=>this.onNextMonthClick(e));
    controls.appendChild(previousMonth);
    controls.appendChild(this.monthDisplay);
    controls.appendChild(nextMonth);
    calendarCol.appendChild(controls);
    calendarCol.appendChild(calendar);
    for (let i = 0; i < 7; i++) {
      header = document.createElement('span');
      header.classList.add('atom-journal-calendar-dow');
      header.textContent = dows[i];
      dowsRow.appendChild(header);
    }
    calendar.appendChild(dowsRow);
    for (let i = 0; i < 6; i++) {
      row = document.createElement('div');
      row.classList.add('atom-journal-calendar-row');
      for (let j = 0; j < 7; j++) {
        day = document.createElement('a');
        day.classList.add('atom-journal-calendar-day');
        day.textContent = i * 7 + j;
        this.days[i * 7 + j] = day;
        day.addEventListener('click', (e)=>this.onDayClick(e));
        row.appendChild(day);
      }
      calendar.appendChild(row);
    }
    this.element.appendChild(calendarCol);
  }

  AtomJournalView.prototype.onDayClick = function(e) {
    var day;
    day = moment(e.target.dataset.date);
    return this.setDate(day);
  };

  AtomJournalView.prototype.onNextMonthClick = function(e) {
    var c = moment(this.month).add(1, 'month');
    return this.setMonth(c.month(), c.year());
  };

  AtomJournalView.prototype.onPreviousMonthClick = function(e) {
    var c = moment(this.month).subtract(1, 'month');
    return this.setMonth(c.month(), c.year());
  };

  AtomJournalView.prototype.serialize = function() {};

  AtomJournalView.prototype.destroy = function() {
    return this.element.remove();
  };

  AtomJournalView.prototype.getElement = function() {
    return this.element;
  };

  AtomJournalView.prototype.getDate = function() {
    return moment(this.date);
  };

  AtomJournalView.prototype.setDate = function(date) {
    var c, index;
    if (this.date) {
      c = moment([this.date.year(), this.date.month()]);
      c.day(0);
      index = this.date.diff(c, 'days');
      this.days[index].classList.remove('atom-journal-calendar-day-today');
    }
    date = moment(date);
    if (!this.date || this.date.month() !== date.month() || this.date.year() !== date.year()) {
      this.setMonth(date.month(), date.year());
    }
    this.date = date;
    c = moment([date.year(), date.month()]);
    c.day(0);
    index = date.diff(c, 'days');
    return this.days[index].classList.add('atom-journal-calendar-day-today');
  };

  AtomJournalView.prototype.getMonth = function() {
    return this.month;
  };

  AtomJournalView.prototype.setMonth = function(month, year) {
    var c, date, i, k, results;
    c = moment([year, month, 1]);
    this.month = moment(c);
    this.monthDisplay.textContent = c.format('MMMM YYYY');
    c.day(0);
    results = [];
    for (i = k = 0; k <= 41; i = ++k) {
      date = this.days[i];
      date.textContent = c.format('D');
      date.dataset.date = c;
      date.classList.toggle('atom-journal-calendar-day-different-month', c.month() !== month);
      date.classList.remove('atom-journal-calendar-day-today');
      results.push(c.add(1, 'day'));
    }
    return results;
  };

  return AtomJournalView;
})();
