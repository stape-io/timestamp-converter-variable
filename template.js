const makeInteger = require('makeInteger');
const Math = require('Math');
const getTimestampMillis = require('getTimestampMillis');

const leapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
const nonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

function convertTimestampToISO(timestamp) {
  const daysSinceEpoch = Math.floor(timestamp / (1000 * 60 * 60 * 24));
  let hoursSinceYesterday = Math.floor(
    (timestamp - daysSinceEpoch * (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
  );
  let minutesSinceYesterday = Math.floor(
    (timestamp -
      daysSinceEpoch * (1000 * 60 * 60 * 24) -
      hoursSinceYesterday * (1000 * 60 * 60)) /
      (1000 * 60)
  );
  let secondsSinceYesterday = Math.floor(
    (timestamp -
      daysSinceEpoch * (1000 * 60 * 60 * 24) -
      hoursSinceYesterday * (1000 * 60 * 60) -
      minutesSinceYesterday * 1000 * 60) /
      1000
  );
  let milliSeconds = Math.floor(
    (secondsSinceYesterday - Math.floor(secondsSinceYesterday)) * 1000
  );

  let startYear = 1970;
  let startMonth = 1;
  let dayCounter = 0;
  const approxYears = daysSinceEpoch / 365;

  while (dayCounter < daysSinceEpoch && startYear - 1969 < approxYears) {
    if (startYear % 4 === 0) {
      dayCounter = dayCounter + 366;
    } else {
      dayCounter = dayCounter + 365;
    }
    startYear++;
  }

  let remainingDays = daysSinceEpoch + 1 - dayCounter;
  const calcYear = startYear % 4 !== 0 ? nonLeapYear : leapYear;

  let monthdayCounter = calcYear[0];
  while (monthdayCounter < remainingDays) {
    startMonth++;
    if (monthdayCounter + calcYear[startMonth - 1] > remainingDays) {
      break;
    }
    monthdayCounter = monthdayCounter + calcYear[startMonth - 1];
  }

  remainingDays =
    startMonth !== 1 ? remainingDays - monthdayCounter : remainingDays;

  let startDate = remainingDays;

  startMonth = startMonth < 10 ? '0' + startMonth : startMonth;
  startDate = startDate < 10 ? '0' + startDate : startDate;
  hoursSinceYesterday =
    hoursSinceYesterday < 10 ? '0' + hoursSinceYesterday : hoursSinceYesterday;
  minutesSinceYesterday =
    minutesSinceYesterday < 10
      ? '0' + minutesSinceYesterday
      : minutesSinceYesterday;
  secondsSinceYesterday =
    secondsSinceYesterday < 10
      ? '0' + secondsSinceYesterday
      : secondsSinceYesterday;

  if (milliSeconds < 10) {
    milliSeconds = '00' + milliSeconds;
  } else if (milliSeconds < 100) {
    milliSeconds = '0' + milliSeconds;
  }

  // Variables must return a value.
  return (
    startYear +
    '-' +
    startMonth +
    '-' +
    startDate +
    'T' +
    hoursSinceYesterday +
    ':' +
    minutesSinceYesterday +
    ':' +
    secondsSinceYesterday +
    '.' +
    milliSeconds +
    'Z'
  );
}

function convertISOToTime(dateTime) {
  const dateArray = dateTime.split('T')[0].split('-');
  const timeArray = dateTime.split('T')[1].split(':');

  const year = makeInteger(dateArray[0]);
  const month = makeInteger(dateArray[1]);
  const day = makeInteger(dateArray[2]);
  const hour = makeInteger(timeArray[0]);
  const minutes = makeInteger(timeArray[1]);
  const seconds = makeInteger(timeArray[2]);

  let yearCounter = 1970;
  let unixTime = 0;

  while (yearCounter < year) {
    if (yearCounter % 4 === 0) {
      unixTime += 31622400;
    } else {
      unixTime += 31536000;
    }
    yearCounter++;
  }

  const monthList = yearCounter % 4 === 0 ? leapYear : nonLeapYear;

  let monthCounter = 1;
  while (monthCounter < month) {
    unixTime += monthList[monthCounter - 1] * 86400;
    monthCounter++;
  }

  let dayCounter = 1;
  while (dayCounter < day) {
    unixTime += 86400;
    dayCounter++;
  }

  let hourCounter = 0;
  while (hourCounter < hour) {
    unixTime += 3600;
    hourCounter++;
  }

  let minutesCounter = 0;
  while (minutesCounter < minutes) {
    unixTime += 60;
    minutesCounter++;
  }

  let secondsCounter = 0;
  while (secondsCounter < seconds) {
    unixTime += 1;
    secondsCounter++;
  }

  return unixTime;
}

const type = data.type;

if (type === 'to_iso') {
  return convertTimestampToISO(
    data.timestamp === 'current_timestamp'
      ? getTimestampMillis()
      : makeInteger(data.timestamp+'000')
  );
} else if (type === 'to_timestamp') {
  return makeInteger(convertISOToTime(data.iso8601DateTime));
} else {
  return 'Invalid type';
}
