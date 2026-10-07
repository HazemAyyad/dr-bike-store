import 'dart:async';

import 'package:doctor_bike/controller/product/review_controller.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/model/commint_model.dart';
import 'package:doctor_bike/repository/product/review_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Map<String, dynamic> own({
    String status = 'pending',
    int rating = 5,
    bool verified = false,
  }) => {
    'id': 3,
    'product_id': 12,
    'rating': rating,
    'comment': 'جيد',
    'status': status,
    'is_verified_purchase': verified,
    'created_at': '2026-10-06T10:00:00Z',
  };
  Map<String, dynamic> publicRow() => {
    'id': 4,
    'productId': 12,
    'rate': 4,
    'comment': 'ممتاز',
    'userName': 'أحمد',
    'dateAdd': '2026-10-06T10:00:00Z',
  };

  test(
    'public published review parsing',
    () => expect(
      Review.fromPublicJson(publicRow()).status,
      ReviewStatus.published,
    ),
  );
  for (final status in ['pending', 'published', 'rejected']) {
    test(
      'own $status review parsing',
      () => expect(Review.fromOwnJson(own(status: status)).status.name, status),
    );
  }
  test(
    'unknown status handled safely',
    () => expect(
      Review.fromOwnJson(own(status: 'future')).status,
      ReviewStatus.unknown,
    ),
  );
  test(
    'rating 1 accepted',
    () => expect(Review.fromOwnJson(own(rating: 1)).rating, 1),
  );
  test('rating 5 accepted', () => expect(Review.fromOwnJson(own()).rating, 5));
  test(
    'rating 0 rejected',
    () =>
        expect(() => Review.fromOwnJson(own(rating: 0)), throwsFormatException),
  );
  test(
    'rating 6 rejected',
    () =>
        expect(() => Review.fromOwnJson(own(rating: 6)), throwsFormatException),
  );
  test(
    'verified purchase only parses server field',
    () => expect(
      Review.fromOwnJson(own(verified: true)).isVerifiedPurchase,
      isTrue,
    ),
  );
  test(
    'pending may edit',
    () => expect(Review.fromOwnJson(own()).canEdit, isTrue),
  );
  test(
    'published cannot edit',
    () => expect(Review.fromOwnJson(own(status: 'published')).canEdit, isFalse),
  );
  test(
    'rejected cannot edit',
    () => expect(Review.fromOwnJson(own(status: 'rejected')).canEdit, isFalse),
  );

  group('review controller', () {
    late FakeReviewRepository repository;
    late ReviewController controller;
    setUp(() {
      Get.testMode = true;
      repository = FakeReviewRepository();
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => true,
        accountRoles: () => ['customer'],
        connectivityCheck: () async => true,
      )..bindProduct(12);
      controller.setRating(5);
      controller.commentController.text = 'جيد';
    });
    test('comment max boundary accepted', () {
      controller.commentController.text = List.filled(5000, 'x').join();
      expect(controller.validate(), isNull);
    });
    test('comment over max rejected', () {
      controller.commentController.text = List.filled(5001, 'x').join();
      expect(controller.validate(), isNotNull);
    });
    test('guest cannot submit', () async {
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => false,
        accountRoles: () => [],
        connectivityCheck: () async => true,
      )..bindProduct(12);
      controller.setRating(5);
      expect(await controller.submit(), isFalse);
      expect(repository.submitCalls, 0);
    });
    test('customer linked may submit', () async {
      expect(await controller.submit(), isTrue);
    });
    test('seller only is customer-required', () async {
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => true,
        accountRoles: () => ['seller'],
        connectivityCheck: () async => true,
      )..bindProduct(12);
      controller.setRating(5);
      expect(await controller.submit(), isFalse);
    });
    test('create sends product id', () async {
      await controller.submit();
      expect(repository.lastProductId, 12);
    });
    test('create sends rating', () async {
      await controller.submit();
      expect(repository.lastRating, 5);
    });
    test('create sends comment', () async {
      await controller.submit();
      expect(repository.lastComment, 'جيد');
    });
    test('client sends no authority fields', () async {
      await controller.submit();
      expect(repository.authorityFieldsSent, isFalse);
    });
    test('201 requires valid data review', () async {
      repository.submitResponse = const Response(
        statusCode: 201,
        body: {
          'data': {'id': 0},
        },
      );
      expect(await controller.submit(), isFalse);
    });
    test('malformed 201 is failure', () async {
      repository.submitResponse = const Response(
        statusCode: 201,
        body: {'ok': true},
      );
      expect(await controller.submit(), isFalse);
    });
    test('new review remains pending from server', () async {
      await controller.submit();
      expect(controller.ownReview?.status, ReviewStatus.pending);
    });
    test('no optimistic public insertion', () async {
      await controller.submit();
      expect(controller.publicState, isA<StoreInitial<List<Review>>>());
    });
    test('own reviews load', () async {
      await controller.loadOwn();
      expect(controller.ownReview?.id, 3);
    });
    test('update sends authoritative fields', () async {
      await controller.loadOwn();
      await controller.updatePending();
      expect(repository.updateArgs, [3, 12, 5, 'جيد']);
    });
    test(
      'real compatibility response is accepted and reloads own reviews',
      () async {
        await controller.loadOwn();
        repository.reloadedOwnRow = {
          ...repository.ownRow,
          'comment': 'جديد',
          'status': 'published',
          'is_verified_purchase': true,
        };
        final callsBefore = repository.ownCalls;
        expect(await controller.updatePending(), isTrue);
        expect(repository.ownCalls, callsBefore + 1);
        expect(controller.ownReview?.comment, 'جديد');
        expect(controller.ownReview?.status, ReviewStatus.published);
        expect(controller.ownReview?.isVerifiedPurchase, isTrue);
      },
    );
    test(
      'isSuccess false is mutation failure and preserves original',
      () async {
        await controller.loadOwn();
        final original = controller.ownReview;
        repository.updateResponse = const Response(
          statusCode: 200,
          body: {'isSuccess': false, 'isFailure': false},
        );
        expect(await controller.updatePending(), isFalse);
        expect(controller.ownReview, same(original));
      },
    );
    test('isFailure true is mutation failure', () async {
      await controller.loadOwn();
      final original = controller.ownReview;
      repository.updateResponse = const Response(
        statusCode: 200,
        body: {'isSuccess': true, 'isFailure': true},
      );
      expect(await controller.updatePending(), isFalse);
      expect(controller.ownReview, same(original));
    });
    test('malformed update 200 is mutation failure', () async {
      await controller.loadOwn();
      repository.updateResponse = const Response(
        statusCode: 200,
        body: {'message': 'success'},
      );
      expect(await controller.updatePending(), isFalse);
      expect(controller.mutationState, ReviewMutationState.failure);
    });
    test('HTTP update failure preserves original review', () async {
      await controller.loadOwn();
      final original = controller.ownReview;
      repository.updateResponse = const Response(statusCode: 500);
      expect(await controller.updatePending(), isFalse);
      expect(controller.ownReview, same(original));
    });
    test(
      'accepted mutation plus reload failure is recoverable sync state',
      () async {
        await controller.loadOwn();
        final original = controller.ownReview;
        repository.ownResponse = const Response(statusCode: 500);
        expect(await controller.updatePending(), isTrue);
        expect(controller.mutationState, ReviewMutationState.syncRequired);
        expect(controller.message, contains('تم حفظ التقييم'));
        expect(controller.ownReview, same(original));
      },
    );
    test('unknown roles let authenticated backend remain authority', () async {
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => true,
        accountRoles: () => null,
        connectivityCheck: () async => true,
      )..bindProduct(12);
      controller.setRating(5);
      expect(controller.rolesKnown, isFalse);
      expect(await controller.submit(), isTrue);
    });
    test('public list loads only public endpoint', () async {
      await controller.loadPublic();
      expect(repository.publicCalls, 1);
      expect(repository.ownCalls, 0);
    });
    test('offline state', () async {
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => true,
        accountRoles: () => ['customer'],
        connectivityCheck: () async => false,
      )..bindProduct(12);
      await controller.loadPublic();
      expect(controller.publicState, isA<StoreOffline<List<Review>>>());
    });
    test('loading state before response', () async {
      final pending = Completer<Response>();
      repository.publicResponse = pending.future;
      final future = controller.loadPublic();
      await Future<void>.delayed(Duration.zero);
      expect(controller.publicState, isA<StoreLoading<List<Review>>>());
      pending.complete(
        Response(
          statusCode: 200,
          body: {
            'rows': [publicRow()],
          },
        ),
      );
      await future;
    });
    test('error state', () async {
      repository.publicStatus = 500;
      await controller.loadPublic();
      expect(controller.publicState, isA<StoreError<List<Review>>>());
    });
    test('public success state', () async {
      await controller.loadPublic();
      expect(controller.publicState, isA<StoreContent<List<Review>>>());
    });
    test('pending success message', () async {
      await controller.submit();
      expect(controller.message, contains('للمراجعة'));
    });
    test('server authorization failure exposes actionable message', () async {
      repository.submitResponse = const Response(
        statusCode: 403,
        body: {'message': 'Account link required'},
      );
      expect(await controller.submit(), isFalse);
      expect(controller.message, contains('حساب عميل نشط'));
    });
    test('invalid rating is blocked client-side', () async {
      controller = ReviewController(
        repository: repository,
        isAuthenticated: () => true,
        accountRoles: () => ['customer'],
        connectivityCheck: () async => true,
      )..bindProduct(12);
      expect(await controller.submit(), isFalse);
    });
  });
}

class FakeReviewRepository implements ReviewDataSource {
  int publicStatus = 200;
  int publicCalls = 0, ownCalls = 0, submitCalls = 0;
  int? lastProductId, lastRating;
  String? lastComment;
  bool authorityFieldsSent = false;
  List<Object?> updateArgs = [];
  Future<Response>? publicResponse;
  Response? submitResponse, updateResponse, ownResponse;
  Map<String, dynamic>? reloadedOwnRow;
  Map<String, dynamic> get ownRow => {
    'id': 3,
    'product_id': 12,
    'rating': 5,
    'comment': 'قديم',
    'status': 'pending',
    'is_verified_purchase': false,
  };
  @override
  Future<Response> publicReviews(int productId) {
    publicCalls++;
    return publicResponse ??
        Future.value(
          Response(
            statusCode: publicStatus,
            body: {
              'rows': [
                {'id': 4, 'productId': 12, 'rate': 4, 'comment': 'ممتاز'},
              ],
            },
          ),
        );
  }

  @override
  Future<Response> ownReviews() async {
    ownCalls++;
    if (ownResponse case final response?) return response;
    return Response(
      statusCode: 200,
      body: {
        'data': [reloadedOwnRow ?? ownRow],
        'meta': {'total': 1},
      },
    );
  }

  @override
  Future<Response> submitReview(
    int productId,
    int rating,
    String? comment,
  ) async {
    submitCalls++;
    lastProductId = productId;
    lastRating = rating;
    lastComment = comment;
    return submitResponse ?? Response(statusCode: 201, body: {'data': ownRow});
  }

  @override
  Future<Response> updatePendingReview(
    int id,
    int productId,
    int rating,
    String? comment,
  ) async {
    updateArgs = [id, productId, rating, comment];
    return updateResponse ??
        const Response(
          statusCode: 200,
          body: {
            'message': 'success',
            'isSuccess': true,
            'error': null,
            'isFailure': false,
          },
        );
  }
}
