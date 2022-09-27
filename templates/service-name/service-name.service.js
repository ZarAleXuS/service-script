// @flow

import { fail, success } from '../../../../util/validator/either';
import { type LoopbackModelInterface } from '../../../utils/types';
import {
/*METHOD_IMPORTS*/
  type ServiceName,
  type ServiceNameModelInstance,
} from './index.flow.js';
import { serviceNameError } from './service-name.error';
import { ServiceNameServiceInterface } from './service-name.interface';

export class ServiceNameService implements ServiceNameServiceInterface {
  serviceNameModel: LoopbackModelInterface<
    ServiceName,
    ServiceNameModelInstance
  >;

  constructor({
    serviceNameModel,
  }: {
    serviceNameModel: LoopbackModelInterface<
      ServiceName,
      ServiceNameModelInstance
    >,
  }) {
    this.serviceNameModel = serviceNameModel;
  }
/*METHOD*/
}
