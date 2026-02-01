import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Allow explicit any for now (18 instances - tech debt)
      '@typescript-eslint/no-explicit-any': 'warn',
      // Allow unused vars prefixed with _, and ignore caught errors
      '@typescript-eslint/no-unused-vars': ['error', { 
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
        caughtErrorsIgnorePattern: '^_?'
      }],
    },
  },
  {
    ignores: ['dist/**', 'node_modules/**', 'landing/**', 'action/**', '*.js'],
  }
);
