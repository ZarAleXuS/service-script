// @flow

import chai from 'chai';
import faker from 'faker';
import sinonChai from 'sinon-chai';
import {
/*METHOD_PARAMS_IMPORTS*/
} from '../../../../../../src/api/services/db/service-name/index.flow';
import { serviceNameError } from '../../../../../../src/api/services/db/service-name/service-name.error';
import { ServiceNameService } from '../../../../../../src/api/services/db/service-name/service-name.service';
import { fail, success } from '../../../../../../src/util/validator/either';
import { serviceNameModel } from '../../../../mock/model/service-name';

chai.use(sinonChai);

describe('[services][db][service-name]', () => {
  let sandbox;

  const serviceNameService = new ServiceNameService({
    serviceNameModel,
  });

  let errorMock;

  beforeEach(() => {
    sandbox = sinon.createSandbox();

    errorMock = new Error(faker.random.words(5));
  });

  afterEach(() => {
    sandbox.restore();
  });
/*METHOD_DESCRIBE*/
});
