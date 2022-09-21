___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Timestamp Converter",
  "description": "This variable helps convert timestamps to other time formats and vice versa.\n\nCurrently supported formats:\n- ISO 8601 string (toISOString format)",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "type",
    "displayName": "Conversion Type",
    "radioItems": [
      {
        "value": "to_iso",
        "displayValue": "Timestamp to ISO 8601 string"
      },
      {
        "value": "to_timestamp",
        "displayValue": "ISO 8601 string to Timestamp"
      }
    ],
    "simpleValueType": true,
    "help": "ISO 8601 is what JS \u003ca target\u003d\"_blank\" href\u003d\"https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString\"\u003etoISOString\u003c/a\u003e method return.\n\u003cbr\u003e\n\u003ca target\u003d\"_blank\" href\u003d\"https://en.wikipedia.org/wiki/ISO_8601\"\u003eMore info about this format.\u003c/a\u003e\n\u003cbr\u003e\u003cbr\u003e\nExample: 2022-02-24T03:00:00.000Z"
  },
  {
    "type": "TEXT",
    "name": "timestamp",
    "displayName": "Timestamp",
    "simpleValueType": true,
    "help": "By default current timestamp will be used",
    "defaultValue": "current_timestamp",
    "enablingConditions": [
      {
        "paramName": "type",
        "paramValue": "to_iso",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "iso8601DateTime",
    "displayName": "Date and time in ISO 8601 format",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "type",
        "paramValue": "to_timestamp",
        "type": "EQUALS"
      }
    ],
    "help": "Example: 2022-02-24T03:00:00.000Z"
  }
]


___SANDBOXED_JS_FOR_SERVER___

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


___TESTS___

scenarios: []


___NOTES___

Created on 19/09/2022, 17:10:53


