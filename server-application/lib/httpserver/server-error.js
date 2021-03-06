var util = require('util');
var winston = require('winston');

var ServerError = function(errorCode, description, err) {
    Error.call(this, 'server error');
    this.errorCode = errorCode;
    this.description = description || _codeToString(errorCode);
    if (errorCode === ServerError.ERR_UNKNOWN) {
        err = err || new Error();
        this.stack = err.stack;
        winston.error(new Date().toString() + '- ServerError: ' + this.errorCode);
        winston.error('\t' + this.stack);
    }
};

ServerError.fromCode = function(code) {
    return new ServerError(code);
};
ServerError.fromDescription = function(description) {
    return new ServerError(ServerError.ERR_UNKOWN, description, new Error());
};
ServerError.fromError = function(err) {
    return new ServerError(ServerError.ERR_UNKOWN, 'ERR_UNKOWN: ' + err.toString(), err);
};

util.inherits(ServerError, Error);

//ErrorCode
ServerError.ERR_UNKNOWN = 1000;
ServerError.ERR_NOT_LOGGED_IN = 1001;
ServerError.ERR_PERMISSION_DENIED = 1002;
ServerError.ERR_NOT_ENOUGH_PARAM = 1003;
ServerError.ERR_USER_NOT_EXIST = 1004;
ServerError.ERR_ITEM_NOT_EXIST = 1005;
ServerError.ALREADY_RELATED = 1006;
ServerError.ALREADY_UNRELATED = 1007;
ServerError.PAGING_NOT_EXIST = 1008;
ServerError.ERR_INCORRECT_ID_OR_PASSWORD = 1009;
ServerError.ERR_TRADE_NOT_EXIST = 1010;
ServerError.ERR_TRADE_STATUS = 1011;
ServerError.ERR_INVALID_COUNTRY = 1012;
ServerError.ERR_INVALID_MOBILE = 1013;
ServerError.ERR_FREQUENT_REQUEST = 1014;
ServerError.ERR_MOBILE_ALREADY_EXIST = 1015;
ServerError.ERR_DUPLICATE_REGISTER = 1016;

var _codeToString = function(code) {
    switch (code) {
        case 1000 :
            return 'ERR_UNKNOWN';
        case 1001 :
            return 'ERR_NOT_LOGGED_IN';
        case 1002 :
            return 'ERR_PERMISSION_DENIED';
        case 1003 :
            return 'ERR_NOT_ENOUGH_PARAM';
        case 1004 :
            return 'ERR_USER_NOT_EXIST';
        case 1005:
            return 'ERR_ITEM_NOT_EXIST';
        case 1006:
            return 'ALREADY_RELATED';
        case 1007:
            return 'ALREADY_UNRELATED';
        case 1008:
            return 'PAGING_NOT_EXIST';
        case 1009:
            return 'ERR_INCORRECT_ID_OR_PASSWORD';
        case 1010:
            return 'ERR_TRADE_NOT_EXIST';
        case 1011:
            return 'ERR_TRADE_STATUS';
        case 1012:
            return 'ERR_INVALID_COUNTRY';
        case 1013:
            return 'ERR_INVALID_MOBILE';
        case 1014:
            return 'ERR_FREQUENT_REQUEST';
        case 1015:
            return 'ERR_MOBILE_ALREADY_EXIST';
        case 1016:
            return 'ERR_DUPLICATE_REGISTER';
    }
};

module.exports = ServerError;
