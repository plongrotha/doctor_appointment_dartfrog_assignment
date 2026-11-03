enum Gender {
  male('MALE', 'Male'),
  female('FEMALE', 'Female'),
  other('OTHER', 'Other')
  ;

  const Gender(this.value, this.label);

  final String value;
  final String label;

  Map<String, String> toJson() => {
    'label': label,
    'value': value,
  };
}
