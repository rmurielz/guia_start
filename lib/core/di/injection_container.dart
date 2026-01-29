import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/repositories/auth_repository_impl.dart';
import 'package:guia_start/data/repositories/edition_repository_impl.dart';
import 'package:guia_start/data/repositories/fair_repository_impl.dart';
import 'package:guia_start/data/repositories/participation_repository_impl.dart';
import 'package:guia_start/data/repositories/third_party_repository_impl.dart';
import 'package:guia_start/data/repositories/user_repository_impl.dart';
import 'package:guia_start/domain/repositories/auth_repository.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';
import 'package:guia_start/domain/repositories/user_repository.dart';

// Auth UseCases
import 'package:guia_start/domain/usecases/auth/sign_in_usecase.dart';
import 'package:guia_start/domain/usecases/auth/sign_out_usecase.dart';
import 'package:guia_start/domain/usecases/auth/sign_up_usecase.dart';

// Edition UseCases
import 'package:guia_start/domain/usecases/edition/create_edition_usecase.dart';
import 'package:guia_start/domain/usecases/edition/get_editions_by_fair_usecase.dart';
import 'package:guia_start/domain/usecases/edition/validate_edition_dates_usecase.dart';

// Fair UseCases
import 'package:guia_start/domain/usecases/fair/create_fair_usecase.dart';
import 'package:guia_start/domain/usecases/fair/delete_fair_usecase.dart';
import 'package:guia_start/domain/usecases/fair/get_all_fair_usecase.dart';
import 'package:guia_start/domain/usecases/fair/get_fair_usecase.dart';
import 'package:guia_start/domain/usecases/fair/get_fair_with_organizer_usecase.dart';
import 'package:guia_start/domain/usecases/fair/search_fairs_usecase.dart';
import 'package:guia_start/domain/usecases/fair/search_fairs_with_organizer_usecase.dart';
import 'package:guia_start/domain/usecases/fair/update_fair_usecase.dart';

// Participation UseCases
import 'package:guia_start/domain/usecases/participation/add_contact_usecase.dart';
import 'package:guia_start/domain/usecases/participation/add_sale_usecase.dart';
import 'package:guia_start/domain/usecases/participation/add_visitor_usecase.dart';
import 'package:guia_start/domain/usecases/participation/calculate_roi_usecase.dart';
import 'package:guia_start/domain/usecases/participation/create_participation_usecase.dart';
import 'package:guia_start/domain/usecases/participation/get_participations_stats_usecase.dart';
import 'package:guia_start/domain/usecases/participation/get_user_participations_usecase.dart';

// Dashboard UseCases
import 'package:guia_start/domain/usecases/dashboard/get_dashboard_stats_usecase.dart';

// ThirdParty UseCases
import 'package:guia_start/domain/usecases/third_party/create_third_party_usecase.dart';
import 'package:guia_start/domain/usecases/third_party/search_third_party_usecase.dart';

/// Dependency Injection Container
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // ===== DATA SOURCES =====

  final FirestoreDatasource _dataSource = FirestoreDatasource();

  // ===== REPOSITORIES =====

  late final AuthRepository authRepository = AuthRepositoryImpl();

  late final EditionRepository editionRepository = EditionRepositoryImpl(
    dataSource: _dataSource,
  );

  late final FairRepository fairRepository = FairRepositoryImpl(
    dataSource: _dataSource,
  );

  late final ParticipationRepository participationRepository =
      ParticipationRepositoryImpl(
    dataSource: _dataSource,
  );

  late final ThirdPartyRepository thirdPartyRepository =
      ThirdPartyRepositoryImpl(
    dataSource: _dataSource,
  );

  late final UserRepository userRepository = UserRepositoryImpl(
    dataSource: _dataSource,
  );

  // ===== USECASES - AUTH =====

  late final SignInUseCase signInUseCase = SignInUseCase(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  late final SignOutUseCase signOutUseCase = SignOutUseCase(authRepository);

  late final SignUpUseCase signUpUseCase = SignUpUseCase(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  // ===== USECASES - EDITION =====

  late final CreateEditionUseCase createEditionUseCase = CreateEditionUseCase(
    editionRepository: editionRepository,
    fairRepository: fairRepository,
  );

  late final GetEditionsByFairUseCase getEditionsByFairUseCase =
      GetEditionsByFairUseCase(editionRepository);

  late final ValidateEditionDatesUseCase validateEditionDatesUseCase =
      ValidateEditionDatesUseCase(editionRepository);

  // ===== USECASES - FAIR =====

  late final CreateFairUseCase createFairUseCase = CreateFairUseCase(
    fairRepository: fairRepository,
    thirdPartyRepository: thirdPartyRepository,
  );

  late final DeleteFairUseCase deleteFairUseCase =
      DeleteFairUseCase(fairRepository);

  late final GetAllFairsUseCase getAllFairsUseCase =
      GetAllFairsUseCase(fairRepository);

  late final GetFairUseCase getFairUseCase = GetFairUseCase(fairRepository);

  late final GetFairWithOrganizerUseCase getFairWithOrganizerUseCase =
      GetFairWithOrganizerUseCase(
    fairRepository: fairRepository,
    thirdPartyRepository: thirdPartyRepository,
  );

  late final SearchFairsUseCase searchFairsUseCase =
      SearchFairsUseCase(fairRepository);

  late final SearchFairsWithOrganizerUseCase searchFairsWithOrganizerUseCase =
      SearchFairsWithOrganizerUseCase(
    fairRepository: fairRepository,
    thirdPartyRepository: thirdPartyRepository,
  );

  late final UpdateFairUseCase updateFairUseCase =
      UpdateFairUseCase(fairRepository);

  // ===== USECASES - PARTICIPATION =====

  late final AddContactUseCase addContactUseCase =
      AddContactUseCase(participationRepository);

  late final AddSaleUseCase addSaleUseCase =
      AddSaleUseCase(participationRepository);

  late final AddVisitorUseCase addVisitorUseCase =
      AddVisitorUseCase(participationRepository);

  late final CalculateROIUseCase calculateROIUseCase =
      CalculateROIUseCase(participationRepository);

  late final CreateParticipationUseCase createParticipationUseCase =
      CreateParticipationUseCase(
    participationRepository: participationRepository,
    editionRepository: editionRepository,
    fairRepository: fairRepository,
  );

  late final GetDashboardStatsUseCase getDashboardStatsUseCase =
      GetDashboardStatsUseCase(
    participationRepository: participationRepository,
    editionRepository: editionRepository,
  );

  late final GetParticipationsStatsUseCase getParticipationsStatsUseCase =
      GetParticipationsStatsUseCase(participationRepository);

  late final GetUserParticipationsUseCase getUserParticipationsUseCase =
      GetUserParticipationsUseCase(
    participationRepository: participationRepository,
    fairRepository: fairRepository,
    editionRepository: editionRepository,
  );

  // ===== USECASES - THIRD PARTY =====

  late final CreateThirdPartyUseCase createThirdPartyUseCase =
      CreateThirdPartyUseCase(thirdPartyRepository);

  late final SearchThirdPartyUseCase searchThirdPartyUseCase =
      SearchThirdPartyUseCase(thirdPartyRepository);
}

// Helper global
final di = InjectionContainer();
