class HomeListData {
  HomeListData({
    this.status,
    this.images,
  });
  String? status = "";
  List<Images>? images = [];

  HomeListData.fromJson(Map<String, dynamic> json) {
    if (json['status'] != null) status = json['status'];
    if (json['images'] != null)
      images =
          List.from(json['images']).map((e) => Images.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['images'] = images?.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Images {
  Images({
    this.xtImage,
    this.id,
  });
  String? xtImage = "";
  String? id = "";

  Images.fromJson(Map<String, dynamic> json) {
    if (json['xt_image'] != null) xtImage = json['xt_image'];
    if (json['id'] != null) id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['xt_image'] = xtImage;
    _data['id'] = id;
    return _data;
  }
}
