part of 'onboarding_cubit.dart';



class OnBoardingState extends Equatable {
  const OnBoardingState({this.currentPage = 0});

  final int currentPage;

  OnBoardingState copyWith({int? currentPage}) {
    return OnBoardingState(currentPage: currentPage ?? this.currentPage);
  }

  @override
  List<Object?> get props => [currentPage];
}