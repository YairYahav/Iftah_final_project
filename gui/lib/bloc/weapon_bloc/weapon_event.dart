// ignore_for_file: must_be_immutable

part of 'weapon_bloc.dart';

abstract class WeaponEvent {
  const WeaponEvent();
}



class SafeSwitchOneFlippedEvent extends WeaponEvent {
  bool value;
  SafeSwitchOneFlippedEvent(this.value);
}

class SafeSwitchTwoFlippedEvent extends WeaponEvent {
  bool value;
  SafeSwitchTwoFlippedEvent(this.value);
}
