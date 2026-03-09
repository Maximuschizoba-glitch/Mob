import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required StorageService storageService,
  })  : _authRepository = authRepository,
        _storageService = storageService,
        super(const AuthInitial());

  final AuthRepository _authRepository;
  final StorageService _storageService;


  StreamSubscription<String>? _fcmTokenRefreshSub;


  User? _lastKnownUser;


  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());


    if (_storageService.isGuestMode()) {
      emit(const GuestMode());
      return;
    }


    final result = await _authRepository.checkAuthStatus();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user.isGuest) {
          emit(const GuestMode());
        } else {
          _lastKnownUser = user;
          emit(Authenticated(user));
          _registerFcmToken();
        }
      },
    );
  }


  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (user) {

        _storageService.setGuestMode(false);
        _lastKnownUser = user;
        emit(Authenticated(user));
        _registerFcmToken();
      },
    );
  }


  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (user) {

        _storageService.setGuestMode(false);
        _lastKnownUser = user;
        emit(Authenticated(user));
        _registerFcmToken();
      },
    );
  }


  Future<void> logout() async {
    emit(const AuthLoading());

    await _authRepository.logout();
    await _storageService.setGuestMode(false);
    await _storageService.clearAll();

    emit(const Unauthenticated());
  }


  Future<void> forceLogout() async {
    await _storageService.setGuestMode(false);
    await _storageService.clearAll();
    emit(const Unauthenticated());
  }


  Future<void> continueAsGuest() async {
    await _storageService.setGuestMode(true);


    final result = await _authRepository.guestLogin();
    result.fold(

      (_) => emit(const GuestMode()),
      (_) => emit(const GuestMode()),
    );
  }


  Future<void> sendOtp({required String phone}) async {
    emit(const AuthLoading());

    final result = await _authRepository.sendOtp(phone: phone);

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) {
        emit(OtpSent(phone: phone));


        if (_lastKnownUser != null) {
          emit(Authenticated(_lastKnownUser!));
        }
      },
    );
  }


  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepository.verifyOtp(
      phone: phone,
      otp: otp,
    );

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (user) {
        _lastKnownUser = user;
        emit(OtpVerified(user: user));


        emit(Authenticated(user));
      },
    );
  }


  Future<void> resendEmailVerification() async {
    emit(const AuthLoading());


    final result = await _authRepository.getUser();

    result.fold(
      (failure) => emit(_mapFailureToAuthError(failure)),
      (_) {
        emit(const EmailVerificationSent());


        if (_lastKnownUser != null) {
          emit(Authenticated(_lastKnownUser!));
        }
      },
    );
  }


  Future<void> refreshUser() async {
    final result = await _authRepository.getUser();

    result.fold(

      (_) {},
      (user) {
        if (user.isGuest) {
          emit(const GuestMode());
        } else {
          _lastKnownUser = user;
          emit(Authenticated(user));
        }
      },
    );
  }


  bool get isGuest => state is GuestMode;


  bool get isAuthenticated => state is Authenticated;


  User? get currentUser =>
      state is Authenticated ? (state as Authenticated).user : _lastKnownUser;


  AuthError _mapFailureToAuthError(Failure failure) {
    if (failure is ValidationFailure) {
      return AuthError(
        message: failure.message,
        validationErrors: failure.errors,
      );
    }
    return AuthError(message: failure.message);
  }


  void _registerFcmToken() {
    unawaited(_doFcmRegistration());
    _setupFcmTokenRefreshListener();
  }

  Future<void> _doFcmRegistration() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      final deviceType = Platform.isIOS ? 'ios' : 'android';
      await _authRepository.registerFcmToken(
        token: token,
        deviceType: deviceType,
      );
    } catch (_) {

    }
  }

  void _setupFcmTokenRefreshListener() {

    if (_fcmTokenRefreshSub != null) return;
    _fcmTokenRefreshSub =
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        final deviceType = Platform.isIOS ? 'ios' : 'android';
        await _authRepository.registerFcmToken(
          token: newToken,
          deviceType: deviceType,
        );
      } catch (_) {

      }
    });
  }

  @override
  Future<void> close() {
    _fcmTokenRefreshSub?.cancel();
    return super.close();
  }
}
