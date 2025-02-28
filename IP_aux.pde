// Extrai IP da mensagem de sincronismo do ESP
String extractIP(String text) {
    String[] parts = text.split("IP: ");
    if (parts.length > 1) {
        String[] ipParts = parts[1].split(","); // Divide o restante para pegar só o IP
        return ipParts[0].trim();
    }
    return null; // Retorna nulo caso não encontre o IP
}

// Função para obter o IP local da máquina
String getLocalIPAddress() {
    try {
        return java.net.InetAddress.getLocalHost().getHostAddress();
    } catch (Exception e) {
        e.printStackTrace();
        return "Não foi possível obter o IP";
    }
}
