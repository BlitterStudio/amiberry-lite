/*      _______   __   __   __   ______   __   __   _______   __   __
 *     / _____/\ / /\ / /\ / /\ / ____/\ / /\ / /\ / ___  /\ /  |\/ /\
 *    / /\____\// / // / // / // /\___\// /_// / // /\_/ / // , |/ / /
 *   / / /__   / / // / // / // / /    / ___  / // ___  / // /| ' / /
 *  / /_// /\ / /_// / // / // /_/_   / / // / // /\_/ / // / |  / /
 * /______/ //______/ //_/ //_____/\ /_/ //_/ //_/ //_/ //_/ /|_/ /
 * \______\/ \______\/ \_\/ \_____\/ \_\/ \_\/ \_\/ \_\/ \_\/ \_\/
 *
 * Copyright (c) 2004 - 2008 Olof Naessén and Per Larsson
 *
 *
 * Per Larsson a.k.a finalman
 * Olof Naessén a.k.a jansem/yakslem
 *
 * Visit: http://guichan.sourceforge.net
 *
 * License: (BSD)
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of Guichan nor the names of its contributors may
 *    be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef GCN_CONTRIB_SDLTRUETYPEFONT_HPP
#define GCN_CONTRIB_SDLTRUETYPEFONT_HPP

#include <map>
#include <string>

#include <SDL_ttf.h>
#include "guisan/color.hpp"

#include "guisan/font.hpp"
#include "guisan/platform.hpp"

#include <map>
#include <string>

namespace gcn
{
    class Graphics;

    /**
     * SDL True Type Font implementation of Font. It uses the SDL_ttf library
     * to display True Type Fonts with SDL.
     *
     * NOTE: You must initialize the SDL_ttf library before using this
     *       class. Also, remember to call the SDL_ttf libraries quit
     *       function.
     *
     * @author Walluce Pinkham
     * @author Olof Naessén
     */
    class GCN_EXTENSION_DECLSPEC SDLTrueTypeFont: public Font
    {
    public:

        /**
         * Constructor.
         *     
         * @param filename the filename of the True Type Font.
         * @param size the size the font should be in.
         */
        SDLTrueTypeFont(const std::string& filename, int size);

        /**
         * Destructor.
         */
        ~SDLTrueTypeFont() override;

        /**
         * Sets the spacing between rows in pixels. Default is 0 pixels.
         * The spacing can be negative.
         *
         * @param spacing the spacing in pixels.
         */
        virtual void setRowSpacing(int spacing);

        /**
         * Gets the spacing between rows in pixels.
         *
         * @return the spacing.
         */
        virtual int getRowSpacing();

        /**
         * Sets the spacing between letters in pixels. Default is 0 pixels.
         * The spacing can be negative.
         *
         * @param spacing the spacing in pixels.
         */
        virtual void setGlyphSpacing(int spacing);

        /**
         * Gets the spacing between letters in pixels.
         *
         * @return the spacing.
         */
        virtual int getGlyphSpacing();

        /**
         * Sets the use of anti aliasing..
         *
         * @param antiAlias true for use of anti-aliasing.
         */
        virtual void setAntiAlias(bool antiAlias);

        /**
         * Checks if anti aliasing is used.
         *
         * @return true if anti aliasing is used.
         */
        virtual bool isAntiAlias();

        /**
         * Set the color of the font.
         *
         * @param color the color of the font.
         */
        virtual void setColor(const Color& color);

        // Inherited from Font

        int getWidth(const std::string& text) const override;
        int getHeight() const override;

        void drawString(
            Graphics* graphics, const std::string& text, int x, int y, bool enabled) override;

    protected:
        std::string mFilename;
        TTF_Font *mFont = nullptr;

        int mHeight = 0;
        int mGlyphSpacing = 0;
        int mRowSpacing = 0;

        bool mAntiAlias = true;
        Color mColor;
    };
}

#endif
