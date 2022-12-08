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
const makeString = require('makeString');

const leapYear = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
const nonLeapYear = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

const secToMs = (s) => s * 1000;
const minToMs = (m) => m * secToMs(60);
const hoursToMs = (h) => h * minToMs(60);
const daysToMs = (d) => d * hoursToMs(24);
const padStart = (value, length) => {
  let result = makeString(value);
  while (result.length < length) {
    result = '0' + result;
  }
  return result;
};

function convertTimestampToISO(timestamp) {
  const fourYearsInMs = daysToMs(365 * 4 + 1);
  let year = 1970 + Math.floor(timestamp / fourYearsInMs) * 4;
  timestamp = timestamp % fourYearsInMs;

  while (true) {
    let isLeapYear = year % 4 === 0;
    let nextTimestamp = timestamp - daysToMs(isLeapYear ? 366 : 365);
    if (nextTimestamp < 0) {
      break;
    }
    timestamp = nextTimestamp;
    year = year + 1;
  }

  const daysByMonth = year % 4 === 0 ? leapYear : nonLeapYear;

  let month = 0;
  for (let i = 0; i < daysByMonth.length; i++) {
    let msInThisMonth = daysToMs(daysByMonth[i]);
    if (timestamp > msInThisMonth) {
      timestamp = timestamp - msInThisMonth;
    } else {
      month = i + 1;
      break;
    }
  }
  let date = Math.ceil(timestamp / daysToMs(1));
  timestamp = timestamp - daysToMs(date - 1);
  let hours = Math.floor(timestamp / hoursToMs(1));
  timestamp = timestamp - hoursToMs(hours);
  let minutes = Math.floor(timestamp / minToMs(1));
  timestamp = timestamp - minToMs(minutes);
  let sec = Math.floor(timestamp / secToMs(1));
  timestamp = timestamp - secToMs(sec);
  let milliSeconds = timestamp;

  return (
    year +
    '-' +
    padStart(month, 2) +
    '-' +
    padStart(date, 2) +
    'T' +
    padStart(hours, 2) +
    ':' +
    padStart(minutes, 2) +
    ':' +
    padStart(sec, 2) +
    '.' +
    padStart(milliSeconds, 3) +
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
      : makeInteger(data.timestamp + '000')
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


