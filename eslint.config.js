module.exports = [
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "module",
    },
    rules: {
      indent: ["error", 2],
      "no-unused-vars": "warn",
      // 다른 ESLint 규칙들을 추가할 수 있습니다.
    },
  },
];
