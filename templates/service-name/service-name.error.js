// @flow

import { type GenericErrorType } from '../../../utils/types';
import { dbError, type DbError } from '../db.error';

export type ServiceNameError = /*ERROR_TYPE*/DbError;
    
export const serviceNameError = {
/*ERROR*/  dataBase: dbError,
};
