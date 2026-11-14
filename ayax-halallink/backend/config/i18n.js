const i18next = require('i18next');
const Backend = require('i18next-fs-backend');
const middleware = require('i18next-http-middleware');
const path = require('path');

// Comprehensive list of major global & Muslim-world languages
const supportedLanguages = [
  'en', // English
  'ar', // Arabic (العربية)
  'fr', // French (Français)
  'es', // Spanish (Español)
  'ur', // Urdu (اردو)
  'id', // Indonesian (Bahasa Indonesia)
  'ms', // Malay (Bahasa Melayu)
  'tr', // Turkish (Türkçe)
  'bn', // Bengali (বাংলা)
  'hi', // Hindi (हिन्दी)
  'fa', // Persian/Farsi (فارسی)
  'sw', // Swahili (Kiswahili)
  'ru', // Russian (Русский)
  'de', // German (Deutsch)
  'pt', // Portuguese (Português)
  'zh'  // Chinese (中文)
];

i18next
  .use(Backend)
  .use(middleware.LanguageDetector)
  .init({
    fallbackLng: 'en',
    supportedLngs: supportedLanguages,
    preload: supportedLanguages,
    ns: ['translation'],
    defaultNS: 'translation',
    backend: {
      loadPath: path.join(__dirname, '../locales/{{lng}}/{{ns}}.json')
    },
    detection: {
      order: ['header', 'querystring'],
      lookupQuerystring: 'lang',
      caches: false
    }
  });

module.exports = { i18next, middleware, supportedLanguages };