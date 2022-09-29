  describe('#methodName', () => {
    const paramsMock: MethodNameParams = { /*METHOD_PARAMS*/};

    it('should fail if __BLANK__ throws', async () => {
      const __BLANK__Stub = sandbox
        .stub(serviceNameModel, '__BLANK__')
        .throws(errorMock);

      const result = await serviceNameService.methodName(paramsMock);

      expect(__BLANK__Stub).to.have.been.calledOnceWithExactly({
        __BLANK__,
      });
      expect(result).to.shallowDeepEqual(
        fail(serviceNameError.dataBase.generic(errorMock))
      );
    });

    it('should succeed', async () => {
      const result = await serviceNameService.methodName(paramsMock);

      expect(result).to.shallowDeepEqual(success(__BLANK__));
    });
  });