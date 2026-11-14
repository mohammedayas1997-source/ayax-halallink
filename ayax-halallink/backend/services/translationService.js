const { translate } = require('@vitalets/google-translate-api');

exports.translateMessage = async (text, targetLang) => {
  try {
    if (!text || !targetLang) return text;
    const res = await translate(text, { to: targetLang });
    return res.text;
  } catch (error) {
    console.error('Translation Error:', error.message);
    return text; // Fallback to original text if translation fails
  }
};