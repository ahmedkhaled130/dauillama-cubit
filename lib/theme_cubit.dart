import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'themes.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(darkAppTheme);

  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? lightAppTheme : darkAppTheme);
  }

  bool get isDark => state.brightness == Brightness.dark;
}

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = themeCubit.isDark;

    return IconButton(
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: themeCubit.toggleTheme,
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
