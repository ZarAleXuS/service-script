  async methodName({ /*METHOD_PARAMS*/}: MethodNameParams): MethodNameReturn {
    try {
      const serviceNameInstance = await this.serviceNameModel.__BLANK__(
        __BLANK__
      );

      return success(__BLANK__);
    } catch (error) {
      return fail(serviceNameError.dataBase.generic(error));
    }
  }