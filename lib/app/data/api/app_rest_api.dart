import 'package:dio/dio.dart';
import 'package:safety_check/app/data/models/base_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_rest_api.g.dart';

@RestApi()
abstract class AppRestAPI {
  factory AppRestAPI(Dio dio, {String baseUrl}) = _AppRestAPI;

  @GET("/safety/init")
  Future<BaseResponse?> init(@Queries() Map<String, dynamic> queries);

  @GET("/safety/test")
  Future<BaseResponse?> test(@Queries() Map<String, dynamic> queries);

  @POST("/safety/signin")
  Future<BaseResponse?> signIn(@Queries() Map<String, dynamic> queries);

  @POST("/logout")
  Future<BaseResponse?> logOut();

  @POST("/find_pw")
  Future<BaseResponse?> findPw(@Queries() Map<String, dynamic> queries);

  @GET("/safety/project_list")
  Future<BaseResponse?> getProjectList(@Queries() Map<String, dynamic> queries);

  @POST("/safety/project_submit")
  Future<BaseResponse?> submitProject(@Queries() Map<String, dynamic> queries);

  @GET("/safety/drawing_list")
  Future<BaseResponse?> getDrawingList(@Queries() Map<String, dynamic> queries);

  @GET("/safety/drawing_memo_submit")
  Future<BaseResponse?> submitDrawingMemo(
      @Queries() Map<String, dynamic> queries);

  @GET("/safety/drawing_memo_delete")
  Future<BaseResponse?> deleteDrawingMemo(
      @Queries() Map<String, dynamic> queries);

  @GET("/safety/marker_list")
  Future<BaseResponse?> getMarkerList(@Queries() Map<String, dynamic> queries);

  @POST("/safety/marker_submit")
  Future<BaseResponse?> submitMarker(@Queries() Map<String, dynamic> queries);

  @POST("/safety/marker_delete")
  Future<BaseResponse?> deleteMarker(@Queries() Map<String, dynamic> queries);

  @POST("/safety/marker_override")
  Future<BaseResponse?> overrideMarker(@Queries() Map<String, dynamic> queries);

  @POST("/safety/marker_merge")
  Future<BaseResponse?> mergeMarker(@Queries() Map<String, dynamic> queries);

  @POST("/safety/marker_sort")
  Future<BaseResponse?> sortMarker(@Queries() Map<String, dynamic> queries);

  @POST("/safety/fault_submit") // 생성 + 수정
  Future<BaseResponse?> submitFault(@Queries() Map<String, dynamic> queries);

  @POST("/safety/fault_delete")
  Future<BaseResponse?> deleteFault(@Queries() Map<String, dynamic> queries);

  @POST("/safety/picture_list")
  Future<BaseResponse?> getPicture(@Queries() Map<String, dynamic> queries);

  @POST("/safety/picture_update")
  Future<BaseResponse?> updatePicture(@Queries() Map<String, dynamic> queries);

  @POST("/upload/safety/picture")
  Future<BaseResponse?> uploadPicture(@Body() FormData data);

  @POST("/safety/picture_delete")
  Future<BaseResponse?> deletePicture(@Queries() Map<String, dynamic> queries);

  @POST("/safety/drawing_copy")
  Future<BaseResponse?> copyDrawing(@Queries() Map<String, dynamic> queries);

  @POST("/safety/fault_cate1_add")
  Future<BaseResponse?> addFaultCate1(@Queries() Map<String, dynamic> queries);

  @POST("/safety/fault_cate2_add")
  Future<BaseResponse?> addFaultCate2(@Queries() Map<String, dynamic> queries);

  @POST("/safety/fault_elem_add")
  Future<BaseResponse?> addFaultElem(@Queries() Map<String, dynamic> queries);
}
