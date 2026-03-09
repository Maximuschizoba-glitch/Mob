import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_cubit.dart';


class AuthProvider extends StatelessWidget {
  const AuthProvider({
    super.key,
    required this.dioClient,
    required this.storageService,
    required this.secureStorage,
    required this.prefs,
    required this.child,
  });

  final DioClient dioClient;
  final StorageService storageService;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) {


        final remoteDataSource = AuthRemoteDataSourceImpl(
          dioClient: dioClient,
        );

        final localDataSource = AuthLocalDataSourceImpl(
          secureStorage: secureStorage,
          prefs: prefs,
        );

        final repository = AuthRepositoryImpl(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
        );

        return AuthCubit(
          authRepository: repository,
          storageService: storageService,
        );
      },
      child: child,
    );
  }
}
