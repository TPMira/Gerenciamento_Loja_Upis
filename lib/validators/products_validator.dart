class ProductValidator{

  String validateImages(List images){
    if(images.isEmpty) return "Adicione imagens do produto";
    return null;
  }

  String validateTitle(String text) {
    if (text.isEmpty) {
      return "preencha o titulo do produto";
  }else if(text.length > 21){
    return "Titulo deve ter no maximo 21 caracteres";
  }
  return null;
  }
  
  String validateDescription(String text){
    if(text.isEmpty) return "preencha a descrição do produto";
    return null;
  }
  
  String validatePrice(String text){
    double price = double.tryParse(text);
    if(price != null){
      if(!text.contains(".") || text.split(".")[1].length != 2)
        return "Utilize duas casas decimais";
    }else{
      return "Preço invalido";
    }
    return null;
  }
  
}