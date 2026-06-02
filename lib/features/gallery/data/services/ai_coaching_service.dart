import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class AiCoachingService {
  final Dio _dio = Dio();

  Future<String> getCritique({
    required String imagePath,
    required String apiKey,
    required String model,
  }) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final isGeminiKey = apiKey.trim().startsWith('AIzaSy');

      if (isGeminiKey) {
        // Direct Gemini API Call
        String geminiModel = 'gemini-2.0-flash';
        if (model.contains('flash-1.5')) {
          geminiModel = 'gemini-1.5-flash';
        } else if (model.contains('pro-1.5')) {
          geminiModel = 'gemini-1.5-pro';
        } else if (model.contains('2.0-flash')) {
          geminiModel = 'gemini-2.0-flash';
        }

        final response = await _dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$apiKey',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
          data: {
            'contents': [
              {
                'parts': [
                  {
                    'text': 'Analyze this photo as an expert photography coach. Critique its composition, lighting, subject placement, and alignment. Give 3 clear, constructive, and actionable recommendations for the next attempt. Focus on photographic rules (rule of thirds, leading lines, framing, head room, etc.). Format your response in clean markdown paragraphs with bold headers.',
                  },
                  {
                    'inlineData': {
                      'mimeType': 'image/jpeg',
                      'data': base64Image,
                    },
                  },
                ],
              }
            ],
          },
        );

        if (response.statusCode == 200) {
          final candidates = response.data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'];
            if (content != null) {
              final parts = content['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts.first['text'] as String?;
                if (text != null) {
                  return text;
                }
              }
            }
          }
        }
        throw Exception('Failed to get critique from Gemini API: ${response.statusCode}');
      } else {
        // OpenRouter API Call
        final response = await _dio.post(
          'https://openrouter.ai/api/v1/chat/completions',
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://github.com/Chetan0e/FrameIQ',
              'X-Title': 'FrameIQ Photography Coach',
            },
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
          data: {
            'model': model,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text': 'Analyze this photo as an expert photography coach. Critique its composition, lighting, subject placement, and alignment. Give 3 clear, constructive, and actionable recommendations for the next attempt. Focus on photographic rules (rule of thirds, leading lines, framing, head room, etc.). Format your response in clean markdown paragraphs with bold headers.',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url': 'data:image/jpeg;base64,$base64Image',
                    },
                  },
                ],
              }
            ],
          },
        );

        if (response.statusCode == 200) {
          final choices = response.data['choices'] as List;
          if (choices.isNotEmpty) {
            final content = choices.first['message']['content'] as String;
            return content;
          }
        }
        throw Exception('Failed to get critique from server: ${response.statusCode}');
      }
    } on DioException catch (de) {
      final serverMsg = de.response?.data?['error']?['message'] ?? de.message;
      throw Exception('AI API Error: $serverMsg');
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  Future<String> getMockCritique({
    required double score,
    required String sceneLabel,
    required List<String> suggestions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final buffer = StringBuffer();
    buffer.writeln('### 🤖 FrameIQ AI Coach Critique (Demo Mode)\n');
    buffer.writeln('> [!NOTE]\n> This is a simulated critique since no OpenRouter API key has been added. Add your API Key in Settings to get real image-based feedback!\n');

    buffer.writeln('#### 📊 Composition Score: **${score.round()}/100**');
    if (score >= 85) {
      buffer.writeln('Excellent framing! A score of ${score.round()}% indicates that your primary subject and alignment match high professional standards. The negative space is balanced, and the horizon orientation is level and stable.');
    } else if (score >= 60) {
      buffer.writeln('A solid start, but with room to improve. You succeeded in centering or aligning parts of your frame, but the primary subject could be more clearly distinguished. The overall balance feels a bit off-center or cluttered.');
    } else {
      buffer.writeln('This shot needs substantial realignment. The lines are tilted, or the subject is not set on typical grid intersections, creating visual confusion. Stabilizing the camera is your first priority.');
    }
    buffer.writeln();

    buffer.writeln('#### 📸 Scene Mode: **$sceneLabel**');
    buffer.writeln('You captured this image in **$sceneLabel** mode. In this scenario, the coaching engine expects specific characteristics:');
    if (sceneLabel.toLowerCase().contains('portrait')) {
      buffer.writeln('- Maintaining focus on the eyes.\n- Setting head placement in the upper-third of the frame.\n- Keeping a natural distance from the camera to avoid focal distortion.');
    } else if (sceneLabel.toLowerCase().contains('landscape')) {
      buffer.writeln('- Keeping a perfectly level horizontal line.\n- Aligning the horizon with one of the rule of thirds horizontal divisions.');
    } else {
      buffer.writeln('- Utilizing clean lighting and avoiding distracting clutter in the background.');
    }
    buffer.writeln();

    if (suggestions.isNotEmpty) {
      buffer.writeln('#### 💡 Addressed Suggestions');
      for (final tip in suggestions) {
        buffer.writeln('- *Suggestion observed during capture:* **$tip**');
      }
      buffer.writeln();
    }

    buffer.writeln('#### 🛠 3 Actionable Tips for Your Next Attempt');
    buffer.writeln('1. **Focal Grid Alignment**: Activate the Rule of Thirds overlay and deliberately place your main subject on one of the four crosshairs (power points).');
    buffer.writeln('2. **Utilize Horizon Haptics**: Wait for the subtle physical vibration before pressing the shutter to guarantee your lines are level.');
    buffer.writeln('3. **Mind the Edges**: Scan the boundaries of your viewport before shooting to ensure no half-cutoff objects or distracting backgrounds ruin the composition.');

    return buffer.toString();
  }
}
