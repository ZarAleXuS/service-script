// @flow

import { ServiceName as serviceNameModel } from '../../../../components/helpers/models';
import { ServiceNameService } from './service-name.service';

export const serviceNameService = new ServiceNameService({
  serviceNameModel,
});
