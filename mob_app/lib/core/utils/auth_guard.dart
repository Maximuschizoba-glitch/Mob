import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../shared/widgets/guest_prompt_sheet.dart';


bool requireAuth(BuildContext context, {required String action}) {
  final authState = context.read<AuthCubit>().state;
  if (authState is Authenticated) return true;


  GuestPromptSheet.show(context, action: action);
  return false;
}
