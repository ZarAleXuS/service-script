// @flow

import {
  type ServiceName,
  type ServiceNameModelInstance,
} from '../../../../src/api/services/db/service-name/index.flow';
import { type LoopbackModelInterface } from '../../../../src/api/utils/types';
import { LoopbackModelMock } from '../loopback-model';

export const serviceName = {
  __BLANK__: __BLANK__,
};

export const serviceNameModel: LoopbackModelInterface<
  ServiceName,
  ServiceNameModelInstance
> = new LoopbackModelMock(serviceName, 'serviceName');
