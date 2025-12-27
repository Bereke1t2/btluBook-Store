class UrlConst {
  static const String baseUrl = "http://10.240.68.85:9090";


  static const String loginEndpoint = "/auth/login";
  static const String signupEndpoint = "/auth/signup";
  static const String logoutEndpoint = "/auth/logout";


  static const String booksEndpoint = "/books";
  static const String categoriesEndpoint = "/categories";
  static const String uploadBookEndpoint = "/books/upload";
  static const String downloadBookEndpoint = "/books/download";
  static const String searchBooksEndpoint = "/books/search";


  static const String chatResponseEndpoint = "/chats/responses";
  static const String trueFalseQuestionsEndpoint = "/chats/questions/true-false";
  static const String multipleChoiceQuestionsEndpoint = "/chats/questions/multiple-choice";
  static const String shortAnswerQuestionsEndpoint = "/chats/questions/short-answer";

  static const String userProfileEndpoint ="/users";
  static const String updateProfileEndpoint ="auth/users/update";

}