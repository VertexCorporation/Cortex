import re

with open('lib/chat/screen/widgets/list.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_text = """              child: ScrollFog(
                scrollController: widget.scrollController,
                showBottom: false,
                showTop: false,
                bottomFogHeight: 100.0,
                color: AppColors.senaryColor,
                child: Tiles.buildMessagesList("""

new_text = """              child: ScrollFog(
                scrollController: widget.scrollController,
                showBottom: true,
                showTop: true,
                topFogHeight: MediaQuery.of(context).size.height * 0.05,
                bottomFogHeight: MediaQuery.of(context).size.height * 0.05,
                color: AppColors.background,
                child: Tiles.buildMessagesList("""

content = content.replace(old_text, new_text)

with open('lib/chat/screen/widgets/list.dart', 'w', encoding='utf-8') as f:
    f.write(content)
