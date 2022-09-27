  errorType: (errorMessage: string): ServiceNameError => ({
    type: 'ERROR_TYPE',
    details: new Error(errorMessage),
  }),
