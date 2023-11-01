enum SnackBarEnum {
  info('info'),
  success('success'),
  warning('warning'),
  error('error');

  final String type;
  const SnackBarEnum(this.type);
}

extension ConvertMessage on String {
  SnackBarEnum toEnum() {
    switch (this) {
      case 'info':
        return SnackBarEnum.info;
      case 'success':
        return SnackBarEnum.success;
      case 'warning':
        return SnackBarEnum.warning;
      case 'error':
        return SnackBarEnum.error;
      default:
        return SnackBarEnum.info;
    }
  }
}
